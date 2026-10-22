import '../../../../core/utils/validators.dart';

enum LegalContentType {
  aboutUs('ABOUT_US'),
  termsAndCondition('TERMS_AND_CONDITION'),
  privacyAndPolicy('PRIVACY_AND_POLICY'),
  dataProtection('DATA_PROTECTION');

  final String apiValue;
  const LegalContentType(this.apiValue);

  String localizedTitle([String? langCode]) {
    final code = (langCode ?? AulaValidation.activeLanguageCode).toLowerCase();
    final isEs = code.startsWith('es');
    switch (this) {
      case LegalContentType.aboutUs:
        return isEs ? 'Sobre Nosotros' : 'About Us';
      case LegalContentType.termsAndCondition:
        return isEs ? 'Términos y Condiciones' : 'Terms & Conditions';
      case LegalContentType.privacyAndPolicy:
        return isEs ? 'Política de Privacidad' : 'Privacy Policy';
      case LegalContentType.dataProtection:
        return isEs ? 'Protección de Datos' : 'Data Protection';
    }
  }

  String localizedSubtitle([String? langCode]) {
    final code = (langCode ?? AulaValidation.activeLanguageCode).toLowerCase();
    final isEs = code.startsWith('es');
    switch (this) {
      case LegalContentType.aboutUs:
        return isEs
            ? 'Información institucional y valores de Aula 360'
            : 'Institutional information and Aula 360 values';
      case LegalContentType.termsAndCondition:
        return isEs
            ? 'Condiciones y normas de uso de la plataforma'
            : 'Platform terms of service and usage policies';
      case LegalContentType.privacyAndPolicy:
        return isEs
            ? 'Tratamiento y privacidad de datos personales'
            : 'How we collect, use, and protect your personal data';
      case LegalContentType.dataProtection:
        return isEs
            ? 'Protocolos de seguridad y custodia de información'
            : 'Our commitment to student and family data security';
    }
  }

  String localizedFallbackContent([String? langCode]) {
    final code = (langCode ?? AulaValidation.activeLanguageCode).toLowerCase();
    final isEs = code.startsWith('es');
    if (isEs) {
      switch (this) {
        case LegalContentType.aboutUs:
          return 'Aula 360 es una plataforma educativa integral diseñada para optimizar la gestión escolar, el seguimiento pedagógico continuo y la comunicación directa entre familias, estudiantes y equipo docente.\n\nNuestra misión es ofrecer herramientas digitales modernas y accesibles que fomenten la excelencia académica, la transparencia y el acompañamiento personalizado de cada alumno en su trayectoria educativa.\n\nPara consultas institucionales, puedes ponerte en contacto con la dirección del centro educativo a través de los canales habituales de atención a familias.';
        case LegalContentType.termsAndCondition:
          return 'El acceso y uso de la plataforma Aula 360 está sujeto a las directrices y normativas del centro educativo. Los usuarios se comprometen a hacer un uso adecuado y diligente de sus credenciales de acceso, protegiendo la confidencialidad de la información académica y respetando los derechos de todos los miembros de la comunidad educativa.\n\nCualquier uso no autorizado o indebido de las cuentas podrá dar lugar a la suspensión temporal o definitiva del servicio conforme a las normas disciplinarias del centro.';
        case LegalContentType.privacyAndPolicy:
          return 'En Aula 360 la privacidad y la protección de los datos de nuestros estudiantes y familias es una prioridad fundamental.\n\nLos datos recabados se utilizan exclusivamente con fines de gestión académica, comunicación institucional y seguimiento del progreso pedagógico, de conformidad con el Reglamento General de Protección de Datos (RGPD) y la legislación vigente en materia de protección de datos de menores.\n\nLos titulares pueden ejercer sus derechos de acceso, rectificación, supresión y limitación del tratamiento contactando a la secretaría del centro.';
        case LegalContentType.dataProtection:
          return 'Aula 360 aplica medidas técnicas y organizativas de seguridad avanzadas para garantizar la confidencialidad, integridad y disponibilidad de la información escolar.\n\nTodos los datos personales y académicos se custodian bajo estrictos protocolos de cifrado en tránsito (TLS/HTTPS) y en reposo, con controles de acceso restringidos y auditoría continua de seguridad.';
      }
    } else {
      switch (this) {
        case LegalContentType.aboutUs:
          return 'Aula 360 is a comprehensive educational platform designed to streamline school management, provide continuous pedagogical monitoring, and foster direct communication between families, students, and educators.\n\nOur mission is to deliver modern, accessible digital tools that promote academic excellence, transparency, and personalized guidance for each student throughout their educational journey.\n\nFor institutional inquiries, you can contact the academy administration through the standard family support channels.';
        case LegalContentType.termsAndCondition:
          return 'Access to and use of the Aula 360 platform is subject to the guidelines and policies of the educational institution. Users agree to use their login credentials diligently, maintaining the confidentiality of academic information and respecting the rights of all members of the educational community.\n\nAny unauthorized or improper use of accounts may result in temporary or permanent suspension of service in accordance with academy disciplinary policies.';
        case LegalContentType.privacyAndPolicy:
          return 'At Aula 360, student and family privacy and data protection are fundamental priorities.\n\nCollected information is used exclusively for academic administration, institutional communication, and pedagogical tracking, in compliance with the General Data Protection Regulation (GDPR) and applicable child data protection laws.\n\nData subjects may exercise their rights of access, rectification, deletion, and restriction of processing by contacting the academy administration.';
        case LegalContentType.dataProtection:
          return 'Aula 360 implements advanced technical and organizational security measures to ensure the confidentiality, integrity, and availability of school data.\n\nAll personal and academic records are safeguarded under strict encryption protocols in transit (TLS/HTTPS) and at rest, with role-based access control and continuous security auditing.';
      }
    }
  }

  /// Default getters for seamless backward-compatibility.
  String get title => localizedTitle();
  String get subtitle => localizedSubtitle();
  String get fallbackContent => localizedFallbackContent();

  static LegalContentType fromString(String value) {
    return LegalContentType.values.firstWhere(
      (e) => e.apiValue == value || e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LegalContentType.termsAndCondition,
    );
  }
}

class LegalContent {
  final LegalContentType type;
  final String content;
  final DateTime? updatedAt;
  final bool isFallback;

  const LegalContent({
    required this.type,
    required this.content,
    this.updatedAt,
    this.isFallback = false,
  });
}
