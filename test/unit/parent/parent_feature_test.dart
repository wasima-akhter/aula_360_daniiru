import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/features/parent_all/data/datasources/parent_remote_data_source.dart';
import 'package:aula360/features/parent_all/data/dtos/child_attendance_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/child_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/parent_invoice_dto.dart';
import 'package:aula360/features/parent_all/data/repositories/parent_repository_impl.dart';

class ParentMockApiClient extends ApiClient {
  ParentMockApiClient() : super(Dio());

  dynamic responseData;
  int statusCode = 200;
  String? lastGetPath;
  Map<String, dynamic>? lastGetParams;
  String? lastPostPath;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastGetPath = path;
    lastGetParams = queryParameters;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPostPath = path;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }
}

void main() {
  group('Parent DTOs Serialization & Model Mapping', () {
    test('ChildDto parses JSON and maps to ChildModel', () {
      final json = {
        'id': 'stu-101',
        'fullName': 'Lucas Rivera',
        'gradeLevel': '2º ESO',
        'enrollmentNumber': 'ENR-4821',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final dto = ChildDto.fromJson(json);
      expect(dto.id, 'stu-101');
      expect(dto.fullName, 'Lucas Rivera');
      expect(dto.gradeLevel, '2º ESO');
      expect(dto.enrollmentNumber, 'ENR-4821');

      final model = dto.toModel();
      expect(model.id, 'stu-101');
      expect(model.name, 'Lucas Rivera');
      expect(model.grade, '2º ESO');
      expect(model.room, 'ENR-4821');
      expect(model.attendance, 96.0);
    });

    test('ChildAttendanceDto parses JSON and maps to AttendanceRecord', () {
      final json = {
        'id': 'att-1',
        'sessionDate': '2026-10-22 08:30:00',
        'subjectName': 'Matemáticas',
        'status': 'PRESENT',
        'note': 'On time',
      };

      final dto = ChildAttendanceDto.fromJson(json);
      expect(dto.status, 'PRESENT');
      expect(dto.subjectName, 'Matemáticas');

      final record = dto.toRecord();
      expect(record.checkInTime, '08:30');
      expect(record.note, 'On time');
    });

    test('ParentInvoiceDto parses and maps to InvoiceModel', () {
      final json = {
        'id': 'inv-101',
        'invoiceNumber': 'INV-2026-001',
        'title': 'Matrícula Octubre',
        'amount': 350.00,
        'dueDate': '2026-10-31',
        'status': 'PENDING',
        'paidAt': null,
      };

      final dto = ParentInvoiceDto.fromJson(json);
      expect(dto.id, 'inv-101');
      expect(dto.amount, 350.00);

      final model = dto.toModel();
      expect(model.id, 'inv-101');
      expect(model.isPaid, false);
      expect(model.amount, 350.00);
    });
  });

  group('ParentRemoteDataSource - All 6 Endpoints', () {
    late ParentMockApiClient mockClient;
    late ParentRemoteDataSource dataSource;

    setUp(() {
      mockClient = ParentMockApiClient();
      dataSource = ParentRemoteDataSourceImpl(mockClient);
    });

    test('1. getChildren calls GET /parent/children', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'stu-1',
            'fullName': 'Lucas Rivera',
            'grade': '2º ESO',
            'classroom': 'Aula 3B',
          }
        ],
      };

      final children = await dataSource.getChildren();
      expect(mockClient.lastGetPath, '/parent/children');
      expect(children.length, 1);
      expect(children.first.fullName, 'Lucas Rivera');
    });

    test('2. getChildAttendance calls GET /parent/children/:id/attendance', () async {
      mockClient.responseData = {
        'success': true,
        'meta': {'percentage': 95, 'total': 20, 'present': 19, 'absent': 1},
        'data': [
          {
            'id': 'att-1',
            'sessionDate': '2026-10-22',
            'status': 'PRESENT',
            'checkInTime': '08:30',
          }
        ],
      };

      final (meta, list) = await dataSource.getChildAttendance('stu-1');
      expect(mockClient.lastGetPath, '/parent/children/stu-1/attendance');
      expect(meta?.percentage, 95);
      expect(list.length, 1);
    });

    test('3. getChildReports calls GET /parent/children/:id/reports', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'rep-1',
            'date': '2026-10-22',
            'subjectName': 'Matemáticas',
            'teacherName': 'Dña. Sarah Vance',
            'contentCovered': 'Álgebra lineal',
            'status': 'Presente',
          }
        ],
      };

      final reports = await dataSource.getChildReports('stu-1');
      expect(mockClient.lastGetPath, '/parent/children/stu-1/reports');
      expect(reports.length, 1);
      expect(reports.first.subjectName, 'Matemáticas');
    });

    test('4. getChildHomework calls GET /parent/children/:id/homework', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'hw-1',
            'title': 'Ecuaciones',
            'subjectName': 'Matemáticas',
            'teacherName': 'Dña. Sarah Vance',
            'dueDate': '2026-10-29',
            'status': 'PENDING',
          }
        ],
      };

      final homework = await dataSource.getChildHomework('stu-1');
      expect(mockClient.lastGetPath, '/parent/children/stu-1/homework');
      expect(homework.length, 1);
      expect(homework.first.title, 'Ecuaciones');
    });

    test('5. getInvoices calls GET /parent/invoices', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'inv-1',
            'invoiceNumber': 'INV-001',
            'title': 'Octubre Cuota',
            'amount': 450.0,
            'status': 'PENDING',
          }
        ],
      };

      final invoices = await dataSource.getInvoices(status: 'PENDING');
      expect(mockClient.lastGetPath, '/parent/invoices');
      expect(mockClient.lastGetParams?['status'], 'PENDING');
      expect(invoices.length, 1);
    });

    test('6. payInvoice calls POST /parent/invoices/:id/pay', () async {
      mockClient.responseData = {
        'success': true,
        'data': {'clientSecret': 'pi_secret_123'},
      };

      final secret = await dataSource.payInvoice('inv-1');
      expect(mockClient.lastPostPath, '/parent/invoices/inv-1/pay');
      expect(secret, 'pi_secret_123');
    });
  });

  group('ParentRepositoryImpl Integration', () {
    late ParentMockApiClient mockClient;
    late ParentRepositoryImpl repository;

    setUp(() {
      mockClient = ParentMockApiClient();
      final dataSource = ParentRemoteDataSourceImpl(mockClient);
      repository = ParentRepositoryImpl(parentRemoteDataSource: dataSource);
    });

    test('getChildren populates from remote data source', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'stu-live',
            'fullName': 'Elena Rivera',
            'grade': '1º Bachillerato',
            'classroom': 'Aula 1',
          }
        ],
      };

      final children = await repository.getChildren();
      expect(children.first.id, 'stu-live');
      expect(children.first.name, 'Elena Rivera');
    });
  });
}
