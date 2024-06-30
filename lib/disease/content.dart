// ignore_for_file: non_constant_identifier_names

class TreatmentRecommendation {

  Map<String, dynamic> potato(int index) {
    final early = <String, dynamic>{
      'Description':
          'Early blight is caused by the fungus Alternaria solani. It typically appears as dark brown to black spots on the leaves, often with concentric rings giving a "target" appearance. The disease can also affect stems and tubers.',
      'Reason':
          'The fungus thrives in warm, humid conditions. It spreads through infected plant debris, soil, and seed tubers. High humidity and temperatures between 24-29°C (75-85°F) are ideal for the development of early blight.',
      'Treatment': '''
      1. Cultural Practices:
        - Rotate crops with non-host plants (e.g., cereals).
        - Remove and destroy infected plant debris.
        - Use certified disease-free seed tubers.
        - Avoid overhead irrigation to minimize leaf wetness.

      2. Chemical Control:
        - Apply fungicides such as chlorothalonil, mancozeb, or azoxystrobin according to local guidelines and resistance management strategies.

      3. Biological Control:
        - Use biocontrol agents like Trichoderma species that inhibit the growth of Alternaria solani.
      '''
    };

    final late = <String, dynamic>{
      'Description':
          'Late blight is caused by the oomycete Phytophthora infestans. It presents as water-soaked lesions on leaves, stems, and tubers, which rapidly turn dark brown to black. Infected tissues may exhibit a white, fuzzy growth under humid conditions.',
      'Reason':
          'Late blight thrives in cool, moist conditions. It spreads through air-borne spores and can infect plants through rain splash or irrigation. Temperatures between 10-25°C (50-77°F) and high humidity are conducive to disease development.',
      'Treatment': '''
      1. Cultural Practices:
        - Use resistant potato varieties if available.
        - Implement proper crop rotation.
        - Remove and destroy infected plant material.
        - Ensure good field drainage to avoid water accumulation.

      2. Chemical Control:
        - Apply fungicides such as metalaxyl, dimethomorph, or fluopicolide. Follow local guidelines and resistance management strategies.

      3. Biological Control:
        - Use biocontrol agents like Bacillus subtilis that can inhibit the growth of Phytophthora infestans.
      '''
    };

    final unknown = <String, dynamic>{
      'Description': 'Unknown',
      'Reason': 'Unknown',
      'Treatment': 'Unknown'
    };

    if (index == 1) {
      return early;
    } else if (index == 2) {
      return late;
    }

    return unknown;
  }

  Map<String, dynamic> strawberry(int index) {
    final scorch = <String, dynamic>{
      'Description':
          'Leaf scorch is a common disease in strawberries caused by the fungus Diplocarpon earliana. It manifests as small, dark purple to reddish-brown spots on the leaves, which eventually enlarge and merge, causing the leaves to turn brown and dry out. Severely affected leaves may appear scorched and die off.',
      'Reason':
          'The disease thrives in warm, wet conditions, spreading through wind, rain splash, and contaminated tools. Overcrowded plantings with poor air circulation and prolonged leaf wetness are favorable for the development of leaf scorch.',
      'Treatment': '''
      1. Cultural Practices:
        - Remove and destroy infected leaves and debris to reduce sources of infection.
        - Plant strawberries with adequate spacing to ensure good air circulation.
        - Avoid overhead watering to minimize leaf wetness and water plants early in the day to allow leaves to dry.

      2. Chemical Control:
        - Apply fungicides such as captan, myclobutanil, or trifloxystrobin according to local guidelines. Rotate fungicides with different modes of action to prevent resistance.

      3. Biological Control:
        - Use biocontrol agents like Bacillus subtilis or Trichoderma species that can inhibit fungal growth.
      
      4. Resistant Varieties:
        - Whenever possible, plant strawberry varieties that are resistant or less susceptible to leaf scorch.
      '''
    };

    final unknown = <String, dynamic>{
      'Description': 'Unknown',
      'Reason': 'Unknown',
      'Treatment': 'Unknown'
    };

    if (index == 1) {
      return scorch;
    }
    return unknown;
  }

  Map<String, dynamic> tomato(int index) {
    final bacterialSpot = <String, dynamic>{
      'Description':
          'Bacterial spot is caused by several species of Xanthomonas. It appears as small, water-soaked spots on leaves, which turn dark brown to black. The spots may have a yellow halo and can affect leaves, stems, and fruits, leading to defoliation and fruit blemishes.',
      'Reason':
          'The bacteria thrive in warm, wet conditions and spread through rain splash, contaminated tools, and infected seeds or transplants. High humidity and temperatures between 25-30°C (77-86°F) favor the development of bacterial spot.',
      'Treatment': '''
      1. Cultural Practices:
        - Use disease-free seeds and transplants.
        - Rotate crops with non-host plants (e.g., cereals).
        - Remove and destroy infected plant debris.
        - Avoid overhead irrigation to reduce leaf wetness.

      2. Chemical Control:
        - Apply copper-based bactericides or antibiotics like streptomycin according to local guidelines and resistance management strategies.

      3. Biological Control:
        - Use biocontrol agents like Bacillus subtilis that can inhibit the growth of Xanthomonas.
      '''
    };

    final early = <String, dynamic>{
      'Description':
          'Early blight is caused by the fungus Alternaria solani. It typically appears as dark brown to black spots on the leaves, often with concentric rings giving a "target" appearance. The disease can also affect stems and fruits.',
      'Reason':
          'The fungus thrives in warm, humid conditions. It spreads through infected plant debris, soil, and seed tubers. High humidity and temperatures between 24-29°C (75-85°F) are ideal for the development of early blight.',
      'Treatment': '''
      1. Cultural Practices:
        - Rotate crops with non-host plants.
        - Remove and destroy infected plant debris.
        - Use certified disease-free seeds.
        - Avoid overhead irrigation to minimize leaf wetness.

      2. Chemical Control:
        - Apply fungicides such as chlorothalonil, mancozeb, or azoxystrobin according to local guidelines and resistance management strategies.

      3. Biological Control:
        - Use biocontrol agents like Trichoderma species that inhibit the growth of Alternaria solani.
      '''
    };

    final late = <String, dynamic>{
      'Description':
          'Late blight is caused by the oomycete Phytophthora infestans. It presents as water-soaked lesions on leaves, stems, and fruits, which rapidly turn dark brown to black. Infected tissues may exhibit a white, fuzzy growth under humid conditions.',
      'Reason':
          'Late blight thrives in cool, moist conditions. It spreads through air-borne spores and can infect plants through rain splash or irrigation. Temperatures between 10-25°C (50-77°F) and high humidity are conducive to disease development.',
      'Treatment': '''
      1. Cultural Practices:
        - Use resistant tomato varieties if available.
        - Implement proper crop rotation.
        - Remove and destroy infected plant material.
        - Ensure good field drainage to avoid water accumulation.

      2. Chemical Control:
        - Apply fungicides such as metalaxyl, dimethomorph, or fluopicolide. Follow local guidelines and resistance management strategies.

      3. Biological Control:
        - Use biocontrol agents like Bacillus subtilis that can inhibit the growth of Phytophthora infestans.
      '''
    };

    final yellow = <String, dynamic>{
      'Description':
          'Yellow leaf curl virus is caused by the Tomato yellow leaf curl virus (TYLCV), which is transmitted by the whitefly (Bemisia tabaci). Infected plants exhibit yellowing and curling of the leaves, stunted growth, and reduced fruit set.',
      'Reason':
          'The virus spreads through whitefly vectors. Warm temperatures and high whitefly populations favor the spread of TYLCV.',
      'Treatment': '''
      1. Cultural Practices:
        - Use resistant tomato varieties if available.
        - Implement crop rotation and avoid planting tomatoes near susceptible crops.
        - Remove and destroy infected plants to reduce virus sources.
        - Use reflective mulches to repel whiteflies.

      2. Chemical Control:
        - Apply insecticides to control whitefly populations. Use insecticides such as imidacloprid, thiamethoxam, or spinosad according to local guidelines.

      3. Biological Control:
        - Introduce natural enemies of whiteflies, such as parasitic wasps (Encarsia formosa) or predatory insects (Delphastus catalinae).
      '''
    };

    final unknown = <String, dynamic>{
      'Description': 'Unknown',
      'Reason': 'Unknown',
      'Treatment': 'Unknown'
    };

    if (index == 1) {
      return bacterialSpot;
    } else if (index == 2) {
      return early;
    } else if (index == 3) {
      return late;
    } else if (index == 4) {
      return yellow;
    }
    return unknown;
  }
}
