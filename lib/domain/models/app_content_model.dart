import 'commission_model.dart';

class AppContentModel {
  final List<String> carouselImages;
  final String aboutUs;
  final String location;
  final List<CommissionModel> commissions;

  AppContentModel({
    required this.carouselImages,
    required this.aboutUs,
    required this.location,
    required this.commissions,
  });

  factory AppContentModel.fromMap(Map<String, dynamic> map) {
    // Procesar lista de comisiones si existe
    List<CommissionModel> commissionsList = [];
    if (map['commissionsList'] != null) {
      final List<dynamic> list = map['commissionsList'];
      commissionsList = list.asMap().entries.map((entry) {
        return CommissionModel.fromMap(entry.key.toString(), Map<String, dynamic>.from(entry.value));
      }).toList();
    }

    return AppContentModel(
      carouselImages: List<String>.from(map['carouselImages'] ?? []),
      aboutUs: map['aboutUs'] ?? '',
      location: map['location'] ?? '',
      commissions: commissionsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carouselImages': carouselImages,
      'aboutUs': aboutUs,
      'location': location,
      'commissionsList': commissions.map((c) => c.toMap()).toList(),
    };
  }

  factory AppContentModel.empty() {
    return AppContentModel(
      carouselImages: [],
      aboutUs: '',
      location: '',
      commissions: [],
    );
  }

  static List<CommissionModel> get defaultCommissions {
    return [
      CommissionModel(id: '1', name: 'Comisión Social', mission: 'Llevar ayuda y esperanza a los más necesitados de nuestra comunidad.', function: 'Organizar jornadas de alimentación, salud y apoyo emocional.', imageUrl: 'comision_social.png'),
      CommissionModel(id: '2', name: 'Betel "Jovenes de convicción"', mission: 'Formar una generación de jóvenes firmes en la fe y con valores cristianos.', function: 'Reuniones semanales, congresos y actividades de integración.', imageUrl: 'jovenes_conviccion.png'),
      CommissionModel(id: '3', name: 'Familias Firmes', mission: 'Fortalecer el núcleo familiar bajo los principios bíblicos.', function: 'Talleres matrimoniales y consejería familiar.', imageUrl: 'familias_firmes.png'),
      CommissionModel(id: '4', name: 'Oración e Intersección', mission: 'Mantener un altar de oración constante por la iglesia y la nación.', function: 'Cadenas de oración y vigilias mensuales.', imageUrl: 'oracion.png'),
      CommissionModel(id: '5', name: 'Madres que Oran', mission: 'Unir a las madres en oración por el futuro de sus hijos.', function: 'Reuniones de oración y apoyo entre madres.', imageUrl: 'madres_que_oran.png'),
      CommissionModel(id: '6', name: 'Ministerio Infantil', mission: 'Sembrar la semilla de la palabra de Dios en los más pequeños.', function: 'Escuela dominical y eventos infantiles.', imageUrl: 'ministerio_infantil.png'),
      CommissionModel(id: '7', name: 'Equipo Elite Evangelismo', mission: 'Cumplir la gran comisión llevando el mensaje a cada rincón.', function: 'Salidas de evangelización y seguimiento a nuevos creyentes.', imageUrl: 'evangelismo.png'),
      CommissionModel(id: '8', name: 'Destacamento Betel', mission: 'Formar carácter y disciplina en niños y adolescentes.', function: 'Actividades al aire libre y formación de valores.', imageUrl: 'destacamento.png'),
      CommissionModel(id: '9', name: 'Águilas Doradas', mission: 'Honrar y servir a nuestros adultos mayores.', function: 'Actividades de recreación y cuidado espiritual.', imageUrl: 'aguilas_doradas.png'),
      CommissionModel(id: '10', name: 'Servidores de Protocolo', mission: 'Brindar una bienvenida cálida y organizada a cada asistente.', function: 'Ujieres, recepción y logística de servicios.', imageUrl: 'protocolo.png'),
      CommissionModel(id: '11', name: 'Grupo Musical', mission: 'Guiar a la congregación a la presencia de Dios a través de la música.', function: 'Ensayos, dirección de alabanza y adoración.', imageUrl: 'grupo_musical.png'),
      CommissionModel(id: '12', name: 'AudioVisual', mission: 'Servir como canal técnico para que el mensaje llegue con claridad.', function: 'Sonido, luces, proyección y transmisión en vivo.', imageUrl: 'audiovisual.png'),
      CommissionModel(id: '13', name: 'Eventos Especiales', mission: 'Planificar y ejecutar celebraciones que glorifiquen a Dios.', function: 'Aniversarios, conferencias y conciertos.', imageUrl: 'eventos.png'),
      CommissionModel(id: '14', name: 'Educación Cristiana', mission: 'Capacitar a los creyentes en el conocimiento profundo de las escrituras.', function: 'Instituto bíblico y cursos de discipulado.', imageUrl: 'educacion.png'),
      CommissionModel(id: '15', name: 'Redes Sociales', mission: 'Expandir el mensaje de la iglesia en el mundo digital.', function: 'Gestión de contenidos en Instagram, Facebook y YouTube.', imageUrl: 'redes_sociales.png'),
    ];
  }
}
