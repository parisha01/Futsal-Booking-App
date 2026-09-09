class Review {
  final String reviewerName;
  final double rating;
  final String comment;

  const Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });
}

class Court {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final double pricePerHour;
  final String location;
  final String description;
  final List<String> availableSlots; // e.g. "5:00pm"
  final List<Review> reviews;
  final List<String> amenities;

  const Court({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.pricePerHour,
    required this.location,
    required this.description,
    required this.availableSlots,
    this.reviews = const [],
    this.amenities = const [],
  });
}

/// Mock data standing in for a backend, since this assessment
/// only requires the front-end to be implemented.
class CourtRepository {
  static final List<Court> courts = [
    Court(
      id: 'c1',
      name: 'Kathmandu Futsal Arena',
      imageUrl: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800',
      rating: 4.5,
      pricePerHour: 25,
      location: 'Kathmandu, 2.1km away',
      description:
          'Premium indoor court, artificial turf/floodlit. Parking and changing rooms available on-site.',
      availableSlots: ['5:00pm', '6:00pm', '7:00pm', '8:00pm'],
      amenities: const ['Parking', 'Floodlights', 'Changing rooms', 'Water station'],
      reviews: const [
        Review(reviewerName: 'Pujan B.', rating: 5, comment: 'Great court, booking was easy through the app, well-maintained turf and friendly staff.'),
        Review(reviewerName: 'Sita R.', rating: 4, comment: 'Good lighting for evening games, gets busy on weekends.'),
      ],
    ),
    Court(
      id: 'c2',
      name: 'Riverside Futsal Hub',
      imageUrl: 'https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800',
      rating: 4.2,
      pricePerHour: 22,
      location: 'Lalitpur, 3.4km away',
      description: 'Riverside outdoor-feel arena with a covered roof, great for evening bookings.',
      availableSlots: ['4:00pm', '6:00pm', '7:00pm'],
      amenities: const ['Covered roof', 'Parking', 'Floodlights'],
      reviews: const [
        Review(reviewerName: 'Daniel K.', rating: 4, comment: 'Nice atmosphere, a bit far from the city center.'),
      ],
    ),
    Court(
      id: 'c3',
      name: 'Greenfield Sports Zone',
      imageUrl: 'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800',
      rating: 4.8,
      pricePerHour: 30,
      location: 'Bhaktapur, 5.0km away',
      description: 'Top-rated futsal venue with premium turf and full amenities including showers.',
      availableSlots: ['3:00pm', '5:00pm', '6:00pm', '9:00pm'],
      amenities: const ['Showers', 'Parking', 'Floodlights', 'Cafe on-site'],
      reviews: const [
        Review(reviewerName: 'Aisha M.', rating: 5, comment: 'Best court in the area, easily worth the price.'),
      ],
    ),
    Court(
      id: 'c4',
      name: 'Bondi Futsal Arena',
      imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800',
      rating: 4.6,
      pricePerHour: 35,
      location: 'Bondi Beach, Sydney NSW',
      description:
          'Beachside indoor futsal courts with skyline views, professional-grade turf, and full amenities.',
      availableSlots: ['5:00pm', '6:00pm', '7:00pm', '8:00pm'],
      amenities: const ['Parking', 'Floodlights', 'Showers', 'Cafe on-site'],
      reviews: const [
        Review(reviewerName: 'Jack T.', rating: 5, comment: 'Best courts in Sydney, always well maintained and the staff are great.'),
        Review(reviewerName: 'Mia R.', rating: 4, comment: 'A bit pricey but worth it for the quality of the pitch.'),
      ],
    ),
    Court(
      id: 'c5',
      name: 'Melbourne Central Futsal',
      imageUrl: 'https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800',
      rating: 4.3,
      pricePerHour: 28,
      location: 'Melbourne CBD, VIC',
      description:
          'Centrally located multi-court facility popular with corporate leagues and weekend social games.',
      availableSlots: ['4:00pm', '5:00pm', '7:00pm', '9:00pm'],
      amenities: const ['Parking', 'Changing rooms', 'Water station'],
      reviews: const [
        Review(reviewerName: 'Liam H.', rating: 4, comment: 'Great location right in the city, easy to get to after work.'),
      ],
    ),
    Court(
      id: 'c6',
      name: 'Gold Coast Futsal Club',
      imageUrl: 'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800',
      rating: 4.7,
      pricePerHour: 32,
      location: 'Gold Coast, QLD',
      description:
          'Modern indoor futsal club with air conditioning, premium turf, and a strong local competitive scene.',
      availableSlots: ['3:00pm', '6:00pm', '7:00pm', '8:00pm'],
      amenities: const ['Parking', 'Floodlights', 'Showers', 'Changing rooms'],
      reviews: const [
        Review(reviewerName: 'Chloe S.', rating: 5, comment: 'Air conditioned courts make a huge difference in summer. Highly recommend.'),
      ],
    ),
    Court(
      id: 'c7',
      name: 'Perth West Futsal Hub',
      imageUrl: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800',
      rating: 4.1,
      pricePerHour: 24,
      location: 'Perth, WA',
      description:
          'Community-focused futsal hub with flexible hourly bookings and a relaxed, social atmosphere.',
      availableSlots: ['5:00pm', '6:00pm', '8:00pm'],
      amenities: const ['Parking', 'Floodlights'],
      reviews: const [
        Review(reviewerName: 'Noah P.', rating: 4, comment: 'Good value courts, friendly regulars, easy booking process.'),
      ],
    ),
  ];
}
