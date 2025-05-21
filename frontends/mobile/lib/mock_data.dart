import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/payment_info.dart';
import 'package:mobile/models/recipient.dart';

final List<Recipient> dummyRecipients = [
  Recipient(
    id: 'r1',
    auth0UserId: 'auth0|123abc',
    email: 'john.doe@example.com',
    firstName: 'John',
    middleName: 'A.',
    lastName: 'Doe',
    dateOfBirth: DateTime(1985, 6, 15),
    phoneNo: '+1234567890',
    bio: 'A passionate fundraiser and community leader.',
    profilePictureUrl: 'https://example.com/profiles/john_doe.jpg',
    socialMediaHandles: [
      SocialMediaHandle(
        id: 'smh1',
        recipientId: 'r1',
        socialMediaHandle: '@john_doe',
      ),
      SocialMediaHandle(
        id: 'smh2',
        recipientId: 'r1',
        socialMediaHandle: 'john-doe-linkedin',
      ),
    ],
  ),
  Recipient(
    id: 'r2',
    auth0UserId: 'auth0|456def',
    email: 'jane.smith@example.com',
    firstName: 'Jane',
    middleName: '',
    lastName: 'Smith',
    dateOfBirth: DateTime(1990, 11, 30),
    phoneNo: '+1987654321',
    bio: 'Dedicated to education and social causes.',
    profilePictureUrl: null,
    socialMediaHandles: [
      SocialMediaHandle(
        id: 'smh3',
        recipientId: 'r2',
        socialMediaHandle: 'facebook.com/jane.smith',
      ),
    ],
  ),
  Recipient(
    id: 'r3',
    auth0UserId: 'auth0|789ghi',
    email: 'alice.johnson@example.com',
    firstName: 'Alice',
    middleName: 'M.',
    lastName: 'Johnson',
    dateOfBirth: DateTime(1978, 3, 22),
    phoneNo: null,
    bio: 'Healthcare advocate and volunteer.',
    profilePictureUrl: 'https://example.com/profiles/alice_johnson.jpg',
    socialMediaHandles: [],
  ),
  Recipient(
    id: 'r4',
    auth0UserId: 'auth0|abc789',
    email: 'bob.williams@example.com',
    firstName: 'Bob',
    middleName: 'L.',
    lastName: 'Williams',
    dateOfBirth: DateTime(1982, 9, 10),
    phoneNo: '+15551234567',
    bio: 'Environmental activist and researcher.',
    profilePictureUrl: null,
    socialMediaHandles: [
      SocialMediaHandle(
        id: 'smh4',
        recipientId: 'r4',
        socialMediaHandle: '@eco_bob',
      ),
    ],
  ),
  Recipient(
    id: 'r5',
    auth0UserId: 'auth0|def456',
    email: 'charlie.brown@example.com',
    firstName: 'Charlie',
    middleName: '',
    lastName: 'Brown',
    dateOfBirth: DateTime(1995, 1, 20),
    phoneNo: '+16667778888',
    bio: 'Animal welfare advocate.',
    profilePictureUrl: 'https://example.com/profiles/charlie_brown.jpg',
    socialMediaHandles: [
      SocialMediaHandle(
        id: 'smh5',
        recipientId: 'r5',
        socialMediaHandle: '@charlie_cares',
      ),
    ],
  ),
  Recipient(
    id: 'r6',
    auth0UserId: 'auth0|ghi789',
    email: 'david.miller@example.com',
    firstName: 'David',
    middleName: 'E.',
    lastName: 'Miller',
    dateOfBirth: DateTime(1988, 7, 5),
    phoneNo: null,
    bio: 'Community development enthusiast.',
    profilePictureUrl: null,
    socialMediaHandles: [],
  ),
  Recipient(
    id: 'r7',
    auth0UserId: 'auth0|jkl012',
    email: 'eve.davis@example.com',
    firstName: 'Eve',
    middleName: 'S.',
    lastName: 'Davis',
    dateOfBirth: DateTime(1973, 12, 25),
    phoneNo: '+17778889999',
    bio: 'Arts and culture supporter.',
    profilePictureUrl: 'https://example.com/profiles/eve_davis.jpg',
    socialMediaHandles: [
      SocialMediaHandle(
        id: 'smh6',
        recipientId: 'r7',
        socialMediaHandle: 'instagram.com/eve_arts',
      ),
    ],
  ),
  Recipient(
    id: 'r8',
    auth0UserId: 'auth0|mno345',
    email: 'frank.harris@example.com',
    firstName: 'Frank',
    middleName: '',
    lastName: 'Harris',
    dateOfBirth: DateTime(2000, 4, 1),
    phoneNo: '+18889990000',
    bio: 'Youth mentorship advocate.',
    profilePictureUrl: null,
    socialMediaHandles: [],
  ),
  Recipient(
    id: 'r9',
    auth0UserId: 'auth0|pqr678',
    email: 'grace.lee@example.com',
    firstName: 'Grace',
    middleName: 'M.',
    lastName: 'Lee',
    dateOfBirth: DateTime(1992, 10, 18),
    phoneNo: '+19990001111',
    bio: 'Environmental sustainability champion.',
    profilePictureUrl: 'https://example.com/profiles/grace_lee.jpg',
    socialMediaHandles: [
      SocialMediaHandle(
        id: 'smh7',
        recipientId: 'r9',
        socialMediaHandle: '@green_grace',
      ),
      SocialMediaHandle(
        id: 'smh8',
        recipientId: 'r9',
        socialMediaHandle: 'linkedin.com/in/grace-lee',
      ),
    ],
  ),
];

final List<Campaign> dummyCampaigns = [
  Campaign(
    id: 'c1',
    ownerRecipientId: 'r1',
    title: 'Clean Water for All',
    description: 'Providing clean water to communities in need.',
    fundraisingGoal: '10000', // $10,000 goal
    status: CampaignStatus.live,
    category: 'Charity',
    launchDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    submissionDate: DateTime.now().subtract(const Duration(days: 15)),
    verificationDate: DateTime.now().subtract(const Duration(days: 14)),
    campaignDonations: [
      CampaignDonation(
        id: 'd1',
        grossAmount: '250.00',
        serviceFee: '5.00',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        campaignId: 'c1',
      ),
      CampaignDonation(
        id: 'd2',
        grossAmount: '500.00',
        serviceFee: '10.00',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        campaignId: 'c1',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p1',
        title: 'Campaign Kickoff',
        content: 'We have officially launched our campaign!',
        publicPostDate: DateTime.now().subtract(const Duration(days: 10)),
        campaignId: 'c1',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r1'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234567890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456789',
    ),
  ),
  Campaign(
    id: 'c2',
    ownerRecipientId: 'r2',
    title: 'Education for Every Child',
    description: 'Supporting education initiatives worldwide.',
    fundraisingGoal: '50000', // $50,000 goal
    status: CampaignStatus.pendingReview,
    category: 'Education',
    launchDate: null,
    endDate: DateTime.now().add(const Duration(days: 60)),
    submissionDate: DateTime.now().subtract(const Duration(days: 1)),
    campaignDonations: [],
    campaignPosts: [],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r2'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441232347890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456234',
    ),
  ),
  Campaign(
    id: 'c3',
    ownerRecipientId: 'r3',
    title: 'Healthcare Access',
    description: 'Improving healthcare access in rural areas.',
    fundraisingGoal: '20000',
    status: CampaignStatus.completed,
    category: 'Health',
    launchDate: DateTime.now().subtract(const Duration(days: 90)),
    endDate: DateTime.now().subtract(const Duration(days: 10)),
    submissionDate: DateTime.now().subtract(const Duration(days: 100)),
    verificationDate: DateTime.now().subtract(const Duration(days: 95)),
    denialDate: null,
    campaignDonations: [
      CampaignDonation(
        id: 'd3',
        grossAmount: '10000.00',
        serviceFee: '200.00',
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
        campaignId: 'c3',
      ),
      CampaignDonation(
        id: 'd4',
        grossAmount: '12000.00',
        serviceFee: '240.00',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        campaignId: 'c3',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p2',
        title: 'Thank You!',
        content: 'Thanks to all donors, we have reached our goal!',
        publicPostDate: DateTime.now().subtract(const Duration(days: 5)),
        campaignId: 'c3',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r3'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 243234567890,
      chapaBankName: 'Health Bank',
      bankAccountNo: '1234567892342',
    ),
  ),
  Campaign(
    id: 'c4',
    ownerRecipientId: 'r4',
    title: 'Save the Rainforest',
    description: 'Protecting endangered rainforests and biodiversity.',
    fundraisingGoal: '75000',
    status: CampaignStatus.live,
    category: 'Environment',
    launchDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 45)),
    submissionDate: DateTime.now().subtract(const Duration(days: 7)),
    verificationDate: DateTime.now().subtract(const Duration(days: 6)),
    campaignDonations: [
      CampaignDonation(
        id: 'd5',
        grossAmount: '300.00',
        serviceFee: '6.00',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        campaignId: 'c4',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p3',
        title: 'Urgent Action Needed',
        content: 'The rainforest is in danger. Donate now!',
        publicPostDate: DateTime.now().subtract(const Duration(days: 4)),
        campaignId: 'c4',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r4'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234523424,
      chapaBankName: 'Example 2 Bank',
      bankAccountNo: '12345678923',
    ),
  ),
  Campaign(
    id: 'c5',
    ownerRecipientId: 'r5',
    title: 'Rescue Animals Now',
    description: 'Providing shelter and care for abandoned animals.',
    fundraisingGoal: '15000',
    status: CampaignStatus.live,
    category: 'Animal Welfare',
    launchDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 30)),
    submissionDate: DateTime.now().subtract(const Duration(days: 5)),
    verificationDate: DateTime.now().subtract(const Duration(days: 4)),
    campaignDonations: [
      CampaignDonation(
        id: 'd6',
        grossAmount: '100.00',
        serviceFee: '2.00',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        campaignId: 'c5',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p4',
        title: 'Meet Our New Rescues!',
        content: 'Check out the animals we recently saved.',
        publicPostDate: DateTime.now().subtract(const Duration(days: 2)),
        campaignId: 'c5',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r5'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234567890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456789',
    ),
  ),
  Campaign(
    id: 'c6',
    ownerRecipientId: 'r6',
    title: 'Build a Community Center',
    description: 'Creating a space for community activities and events.',
    fundraisingGoal: '100000',
    status: CampaignStatus.pendingReview,
    category: 'Community',
    launchDate: null,
    endDate: DateTime.now().add(const Duration(days: 90)),
    submissionDate: DateTime.now().subtract(const Duration(days: 2)),
    campaignDonations: [],
    campaignPosts: [],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r6'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234567890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456789',
    ),
  ),
  Campaign(
    id: 'c7',
    ownerRecipientId: 'r7',
    title: 'Support Local Artists',
    description: 'Providing grants and opportunities for local artists.',
    fundraisingGoal: '30000',
    status: CampaignStatus.live,
    category: 'Arts and Culture',
    launchDate: DateTime.now().subtract(const Duration(days: 7)),
    endDate: DateTime.now().add(const Duration(days: 35)),
    submissionDate: DateTime.now().subtract(const Duration(days: 9)),
    verificationDate: DateTime.now().subtract(const Duration(days: 8)),
    campaignDonations: [
      CampaignDonation(
        id: 'd7',
        grossAmount: '50.00',
        serviceFee: '1.00',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        campaignId: 'c7',
      ),
      CampaignDonation(
        id: 'd8',
        grossAmount: '75.00',
        serviceFee: '1.50',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        campaignId: 'c7',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p5',
        title: 'Upcoming Art Showcase',
        content: 'Support our campaign to fund the next showcase!',
        publicPostDate: DateTime.now().subtract(const Duration(days: 3)),
        campaignId: 'c7',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r7'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234567890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456789',
    ),
  ),
  Campaign(
    id: 'c8',
    ownerRecipientId: 'r8',
    title: 'Mentoring Young Leaders',
    description: 'Empowering youth through mentorship programs.',
    fundraisingGoal: '25000',
    status: CampaignStatus.completed,
    category: 'Youth',
    launchDate: DateTime.now().subtract(const Duration(days: 60)),
    endDate: DateTime.now().subtract(const Duration(days: 5)),
    submissionDate: DateTime.now().subtract(const Duration(days: 70)),
    verificationDate: DateTime.now().subtract(const Duration(days: 65)),
    denialDate: null,
    campaignDonations: [
      CampaignDonation(
        id: 'd9',
        grossAmount: '5000.00',
        serviceFee: '100.00',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        campaignId: 'c8',
      ),
      CampaignDonation(
        id: 'd10',
        grossAmount: '7000.00',
        serviceFee: '140.00',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        campaignId: 'c8',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p6',
        title: 'Success Stories!',
        content: 'Read about the impact of our mentorship program.',
        publicPostDate: DateTime.now().subtract(const Duration(days: 10)),
        campaignId: 'c8',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r8'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234567890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456789',
    ),
  ),
  Campaign(
    id: 'c9',
    ownerRecipientId: 'r9',
    title: 'Plant Trees for the Future',
    description: 'Reforestation initiative to combat climate change.',
    fundraisingGoal: '40000',
    status: CampaignStatus.live,
    category: 'Environment',
    launchDate: DateTime.now().subtract(const Duration(days: 15)),
    endDate: DateTime.now().add(const Duration(days: 50)),
    submissionDate: DateTime.now().subtract(const Duration(days: 17)),
    verificationDate: DateTime.now().subtract(const Duration(days: 16)),
    campaignDonations: [
      CampaignDonation(
        id: 'd11',
        grossAmount: '200.00',
        serviceFee: '4.00',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        campaignId: 'c9',
      ),
      CampaignDonation(
        id: 'd12',
        grossAmount: '300.00',
        serviceFee: '6.00',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        campaignId: 'c9',
      ),
    ],
    campaignPosts: [
      CampaignPost(
        id: 'p7',
        title: 'Join Our Planting Day!',
        content: 'Volunteer with us to plant new trees.',
        publicPostDate: DateTime.now().subtract(const Duration(days: 12)),
        campaignId: 'c9',
      ),
    ],
    ownerRecipient: dummyRecipients.firstWhere((r) => r.id == 'r9'),
    paymentInfo: PaymentInfo(
      chapaBankCode: 23441234567890,
      chapaBankName: 'Example Bank',
      bankAccountNo: '123456789',
    ),
  ),
];

final List<CampaignRequest> dummyCampaignRequests = [
  GoalAdjustmentRequest(
    id: 'req6',
    campaignId: 'c1', // Linked to 'Clean Water for All'
    ownerRecipientId: 'r1',
    title: 'Request to Increase Goal (Phase 2)',
    justification:
        'Successful initial phase complete. Aiming for a larger impact with an increased target.',
    requestDate: DateTime.now().subtract(const Duration(days: 5)),
    newGoal: '20000', // Requesting to increase goal to 20000
  ),
  EndDateExtensionRequest(
    id: 'req7',
    campaignId: 'c5', // Linked to 'Rescue Animals Now'
    ownerRecipientId: 'r5',
    title: 'Extend Campaign Deadline',
    justification:
        'To accommodate recent partnership opportunities and expand reach.',
    requestDate: DateTime.now().subtract(const Duration(days: 3)),
    newEndDate: DateTime.now()
        .add(const Duration(days: 45)), // Requesting to extend by 15 days
  ),
  StatusChangeRequest(
    id: 'req8',
    campaignId: 'c6', // Linked to 'Build a Community Center' (Pending)
    ownerRecipientId: 'r6',
    title: 'Request for Campaign Approval',
    justification:
        'Completed all required documentation and permits for review.',
    requestDate: DateTime.now().subtract(const Duration(days: 2)),
    newStatus: CampaignStatus.live, // Requesting to change status to live
  ),
  PostUpdateRequest(
    id: 'req9',
    campaignId: 'c9', // Linked to 'Plant Trees for the Future'
    ownerRecipientId: 'r9',
    title: 'Submit New Campaign Update',
    justification:
        'Sharing progress on tree planting locations and volunteer turnout.',
    requestDate: DateTime.now().subtract(const Duration(days: 1)),
    newPost: CampaignPost(
      // Dummy CampaignPost for the request
      id: 'temp_p9', // Temporary ID for the request
      title: 'Update: Planting Progress!',
      content:
          'We planted over 500 trees this weekend thanks to our volunteers!',
      publicPostDate: DateTime.now()
          .subtract(const Duration(hours: 8)), // Date for the *new* post
      campaignId: 'c9',
    ),
  ),
  GoalAdjustmentRequest(
    id: 'req1',
    campaignId: 'c1', // Linked to 'Clean Water for All'
    ownerRecipientId: 'r1',
    title: 'Request to Increase Goal',
    justification:
        'We have received overwhelming support and believe we can reach a higher target.',
    requestDate: DateTime.now().subtract(const Duration(days: 3)),
    newGoal: '15000', // Requesting to increase goal to 15000
  ),
  EndDateExtensionRequest(
    id: 'req2',
    campaignId: 'c4', // Linked to 'Save the Rainforest'
    ownerRecipientId: 'r4',
    title: 'Request to Extend End Date',
    justification:
        'We need more time to reach our goal due to unforeseen challenges.',
    requestDate: DateTime.now().subtract(const Duration(days: 5)),
    resolutionDate: DateTime.now()
        .subtract(const Duration(days: 2)), // Example of a resolved request
    newEndDate: DateTime.now()
        .add(const Duration(days: 60)), // Requesting to extend by 15 days
  ),
  StatusChangeRequest(
    id: 'req3',
    campaignId: 'c2', // Linked to 'Education for Every Child' (Pending)
    ownerRecipientId: 'r2',
    title: 'Request to Change Status to Live',
    justification:
        'All necessary documentation is now complete. Ready to launch.',
    requestDate: DateTime.now().subtract(const Duration(days: 1)),
    newStatus: CampaignStatus.live,
  ),
  PostUpdateRequest(
    id: 'req4',
    campaignId: 'c5', // Linked to 'Rescue Animals Now'
    ownerRecipientId: 'r5',
    title: 'Request to Publish New Update',
    justification: 'Sharing heartwarming success stories of recent rescues.',
    requestDate: DateTime.now().subtract(const Duration(days: 1)),
    newPost: CampaignPost(
      // Dummy CampaignPost for the request
      id: 'temp_p8', // Temporary ID for the request
      title: 'Update: Adoption Success!',
      content: 'Two of our long-term residents have found their forever homes.',
      publicPostDate: DateTime.now()
          .subtract(const Duration(hours: 12)), // Date for the *new* post
      campaignId: 'c5',
    ),
  ),
  GoalAdjustmentRequest(
    id: 'req5',
    campaignId: 'c9', // Linked to 'Plant Trees for the Future'
    ownerRecipientId: 'r9',
    title: 'Second Goal Adjustment Request',
    justification:
        'Due to strong momentum, we are pushing for an even higher target.',
    requestDate: DateTime.now().subtract(const Duration(days: 1)),
    resolutionDate: DateTime.now()
        .subtract(const Duration(hours: 6)), // Another resolved request
    newGoal: '60000', // Requesting to increase goal to 60000
  ),
];
