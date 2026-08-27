class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'RaktDrishti',
      'tagline': 'See the risk. Confirm with confidence.',
      'login_title': 'Frontline Health Worker Login',
      'username': 'Username / Worker ID',
      'password': 'Password / PIN',
      'login_button': 'Secure Login',
      'offline_mode': 'OFFLINE MODE (Local Storage Active)',
      'online_mode': 'ONLINE (Sync Active)',
      'welcome_worker': 'Welcome, {name}',
      'start_screening': 'Start New Screening',
      'total_screenings': 'Total Screenings',
      'high_risk_cases': 'High Risk Cases',
      'pending_sync': 'Pending Sync',
      'active_referrals': 'Active Referrals',
      'patient_name': 'Patient Full Name',
      'age': 'Age (Years)',
      'gender': 'Gender',
      'pregnancy_status': 'Pregnancy Status',
      'village': 'Village / Locality',
      'phone_optional': 'Phone Number (Optional)',
      'register_patient': 'Register Patient',
      'capture_conjunctiva': 'Capture Inner Eyelid (Conjunctiva)',
      'capture_nail': 'Capture Fingernails',
      'capture_palm': 'Capture Open Palm',
      'calib_instruction': 'Place calibration card beside the capture area.',
      'quality_good': 'Image Quality: Optimal',
      'quality_poor': 'Image quality too low. Move to indirect bright light.',
      'analyzing_images': 'Analyzing images...',
      'normalizing_color': 'Normalizing color with calibration card...',
      'generating_result': 'Generating multi-site screening result...',
      'screening_result': 'Screening Result',
      'risk_level': 'Risk Level',
      'confidence': 'Result Confidence',
      'disclaimer': 'RaktDrishti is a screening aid and does not diagnose anemia.',
      'referral_action': 'Generate Confirmatory Lab Referral',
      'sync_completed': 'Sync Completed Successfully',
    },
    'hi': {
      'app_name': 'रक्तदृष्टि',
      'tagline': 'जोखिम पहचानें। विश्वास से पुष्टि करें।',
      'login_title': 'स्वास्थ्य कार्यकर्ता लॉगिन (ASHA / ANM)',
      'username': 'उपयोगकर्ता नाम / कार्यकर्ता आईडी',
      'password': 'पासवर्ड / पिन',
      'login_button': 'सुरक्षित लॉगिन करें',
      'offline_mode': 'ऑफ़लाइन मोड (स्थानीय डेटा सक्रिय)',
      'online_mode': 'ऑनलाइन (डेटा सिंक सक्रिय)',
      'welcome_worker': 'नमस्ते, {name}',
      'start_screening': 'नई एनीमिया जांच शुरू करें',
      'total_screenings': 'कुल जांच',
      'high_risk_cases': 'उच्च जोखिम मामले',
      'pending_sync': 'लंबित सिंक',
      'active_referrals': 'सक्रिय रेफरल',
      'patient_name': 'मरीज का पूरा नाम',
      'age': 'उम्र (वर्ष)',
      'gender': 'लिंग',
      'pregnancy_status': 'गर्भावस्था की स्थिति',
      'village': 'गाँव / क्षेत्र',
      'phone_optional': 'फ़ोन नंबर (वैकल्पिक)',
      'register_patient': 'मरीज का पंजीकरण करें',
      'capture_conjunctiva': 'आँख की निचली पलक की फोटो लें',
      'capture_nail': 'नाखूनों की फोटो लें',
      'capture_palm': 'खुली हथेली की फोटो लें',
      'calib_instruction': 'कैलिब्रेशन कार्ड को फोटो क्षेत्र के पास रखें।',
      'quality_good': 'फोटो की गुणवत्ता: उत्तम',
      'quality_poor': 'फोटो गुणवत्ता कम है। कृपया अच्छी रोशनी में दोबारा फोटो लें।',
      'analyzing_images': 'फोटो का विश्लेषण हो रहा है...',
      'normalizing_color': 'कैलिब्रेशन कार्ड से रंग संतुलित किया जा रहा है...',
      'generating_result': 'स्क्रीनिंग परिणाम तैयार किया जा रहा है...',
      'screening_result': 'स्क्रीनिंग परिणाम',
      'risk_level': 'जोखिम स्तर',
      'confidence': 'परिणाम विश्वसनीयता',
      'disclaimer': 'रक्तदृष्टि एक प्राथमिक स्क्रीनिंग सहायता है, यह नैदानिक पुष्टि नहीं है।',
      'referral_action': 'अस्पताल रक्त जांच रेफरल पर्ची बनाएं',
      'sync_completed': 'डेटा सफलतापूर्वक सिंक हो गया',
    }
  };

  String tr(String key, {Map<String, String>? params}) {
    String text = _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }
}
