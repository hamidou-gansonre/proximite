

class ApiConstants {

  // Si tu testes sur Émulateur Android, '10.0.2.2' pointe vers le localhost de ta machine
  // Si tu testes sur un vrai téléphone, mets l'IP locale de ton PC (ex: http://192.168.1.50:3000)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String pharmaciesProchesEndpoint = '/pharmacies/proximite';

  // Ta clé Google Cloud avec Maps SDK et Directions API activés
  static const String googleMapsApiKey = 'TON_API_KEY_GOOGLE_MAPS';
  static const String googleDirectionSDKApiKey = '';
}