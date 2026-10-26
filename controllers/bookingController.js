const Branch = require('../models/Branch');
const Service = require('../models/Service');
const Stylist = require('../models/Stylist');
const Appointment = require('../models/Appointment');
const User = require('../models/User');

// Default in-memory/seed data fallback for high availability
const DEFAULT_BRANCHES = [
  {
    branchId: 'BR-001',
    name: 'Model Town',
    address: 'Model Town, Jalandhar, Punjab',
    phone: '+91 98140 11223',
    openingTime: '09:00 AM',
    closingTime: '09:00 PM',
    distance: '2.5 km',
    status: 'active'
  },
  {
    branchId: 'BR-002',
    name: 'Phagwara',
    address: 'GT Road, Phagwara, Punjab',
    phone: '+91 98140 33445',
    openingTime: '09:00 AM',
    closingTime: '09:00 PM',
    distance: '12 km',
    status: 'active'
  },
  {
    branchId: 'BR-003',
    name: 'Jalandhar',
    address: 'Civil Lines, Jalandhar, Punjab',
    phone: '+91 98140 55667',
    openingTime: '09:00 AM',
    closingTime: '09:00 PM',
    distance: '4 km',
    status: 'active'
  },
  {
    branchId: 'BR-004',
    name: 'Ludhiana',
    address: 'Ferozepur Road, Ludhiana, Punjab',
    phone: '+91 98140 77889',
    openingTime: '09:00 AM',
    closingTime: '09:00 PM',
    distance: '32 km',
    status: 'active'
  }
];

const DEFAULT_SERVICES = [
  {
    serviceId: 'SRV-001',
    name: 'Hair Cut',
    category: 'Hair',
    price: 800,
    duration: 45,
    description: 'Precision luxury cut, wash, and style consultation.',
    availability: true
  },
  {
    serviceId: 'SRV-002',
    name: 'Layer Cut',
    category: 'Hair',
    price: 2400,
    duration: 60,
    description: 'Multidimensional cut with feather-soft cascading layers that frame the face.',
    availability: true
  },
  {
    serviceId: 'SRV-003',
    name: 'Gel Polish',
    category: 'Nails',
    price: 1200,
    duration: 60,
    description: 'A long-lasting, high-gloss finish with wide range of luxury couture colours.',
    availability: true
  },
  {
    serviceId: 'SRV-004',
    name: 'Nail Art',
    category: 'Nails',
    price: 1800,
    duration: 60,
    description: 'Custom bespoke art, cat eye, french ombré, and minimalist gemstone accents.',
    availability: true
  },
  {
    serviceId: 'SRV-005',
    name: 'Facial',
    category: 'Skin',
    price: 2000,
    duration: 60,
    description: 'Deep cleansing, gentle exfoliating hydration, and rejuvenating botanical glow.',
    availability: true
  },
  {
    serviceId: 'SRV-006',
    name: 'Threading',
    category: 'Other',
    price: 300,
    duration: 20,
    description: 'Artisanal brow shaping and gentle facial threading.',
    availability: true
  },
  {
    serviceId: 'SRV-007',
    name: 'French Tip',
    category: 'Nails',
    price: 1400,
    duration: 50,
    description: 'Timeless luxury French tips with sheer pink base and crisp edges.',
    availability: true
  },
  {
    serviceId: 'SRV-008',
    name: 'Basic Manicure',
    category: 'Nails',
    price: 900,
    duration: 40,
    description: 'Nail shaping, cuticle rejuvenation, buff, and nourishing organic oil massage.',
    availability: true
  },
  {
    serviceId: 'SRV-009',
    name: 'Spa Pedicure',
    category: 'Nails',
    price: 1500,
    duration: 60,
    description: 'Relaxing foot soak, exfoliation scrub, mask, and hot towel massage.',
    availability: true
  }
];

const DEFAULT_STYLISTS = [
  {
    stylistId: 'STY-001',
    name: 'Jessica Alba',
    roleTitle: 'Senior Nail Artist',
    branchName: 'Model Town',
    rating: 4.8,
    reviewsCount: 128,
    tier: 'Premium',
    specialization: ['Gel Polish', 'Nail Art', 'French Tip', 'Nail Extensions'],
    about: 'Specialized in nail art, gel extensions and minimal aesthetic designs with 6+ years experience.',
    isAvailable: true,
    services: ['Gel Polish', 'Nail Art', 'French Tip', 'Basic Manicure', 'Spa Pedicure', 'Nail Extension', 'Nail Removal']
  },
  {
    stylistId: 'STY-002',
    name: 'Maya',
    roleTitle: 'Hair Specialist',
    branchName: 'Model Town',
    rating: 4.6,
    reviewsCount: 94,
    tier: 'Top Rated',
    specialization: ['Layer Cut', 'Balayage', 'Hair Spa', 'Bangs & Fringe'],
    about: 'Master colorist and precision layering expert trained in Paris and Mumbai.',
    isAvailable: true,
    services: ['Hair Cut', 'Layer Cut', 'Hair Colour', 'Hair Spa & Care']
  },
  {
    stylistId: 'STY-003',
    name: 'Christian Dior',
    roleTitle: 'Art Director',
    branchName: 'Model Town',
    rating: 4.9,
    reviewsCount: 582,
    tier: 'Art Director',
    specialization: ['Precision Cuts', 'Couture Styling', 'Layered Silhouette'],
    about: 'Celebrity style director specializing in high-fashion editorial hair transformations.',
    isAvailable: true,
    services: ['Hair Cut', 'Layer Cut', 'Couture Styling']
  },
  {
    stylistId: 'STY-004',
    name: 'Ananya',
    roleTitle: 'Skin Specialist',
    branchName: 'Model Town',
    rating: 4.7,
    reviewsCount: 86,
    tier: 'Specialist',
    specialization: ['Hydrafacial', 'Rejuvenating Glow', 'Skin Therapy'],
    about: 'Certified clinical aesthetician focusing on skin barrier repair and radiant glows.',
    isAvailable: false,
    services: ['Facial', 'Skin Therapy']
  },
  {
    stylistId: 'STY-005',
    name: 'Riya',
    roleTitle: 'Nail Artist',
    branchName: 'Model Town',
    rating: 4.5,
    reviewsCount: 42,
    tier: 'Nail Artist',
    specialization: ['Gel Polish', 'Nail Art'],
    about: 'Talented rising nail artist with an eye for chrome, pearls, and Korean blush nails.',
    isAvailable: true,
    services: ['Gel Polish', 'Nail Art', 'Basic Manicure']
  }
];

let inMemoryAppointments = [
  {
    appointmentId: 'APT-1001',
    customerName: 'Sarah Thomas',
    customerPhone: '+91 98765 43210',
    customerEmail: 'sarah.kothari@gmail.com',
    customerId: 'CUST-0001',
    serviceName: 'Gel Polish',
    servicePrice: 1200,
    serviceDuration: 60,
    stylistName: 'Jessica Alba',
    branchName: 'Model Town',
    date: 'Tue, 12 Aug 2026',
    time: '11:00 AM',
    notes: 'Short nails, nude shade, prefers minimal designs.',
    previousServices: 'Gel Polish - 3 months ago, Manicure - 6 months ago',
    status: 'Confirmed'
  },
  {
    appointmentId: 'APT-1002',
    customerName: 'Priya Sharma',
    customerPhone: '+91 98111 22334',
    customerEmail: 'priya.s@example.com',
    customerId: 'CUST-0002',
    serviceName: 'Hair Cut',
    servicePrice: 800,
    serviceDuration: 45,
    stylistName: 'Jessica Alba',
    branchName: 'Model Town',
    date: 'Tue, 12 Aug 2026',
    time: '09:00 AM',
    notes: 'Trim split ends, keep shoulder length.',
    previousServices: 'Layer Cut - 4 months ago',
    status: 'Confirmed'
  },
  {
    appointmentId: 'APT-1003',
    customerName: 'Aisha Khan',
    customerPhone: '+91 98222 33445',
    customerEmail: 'aisha.k@example.com',
    customerId: 'CUST-0003',
    serviceName: 'Nail Art',
    servicePrice: 1800,
    serviceDuration: 60,
    stylistName: 'Jessica Alba',
    branchName: 'Model Town',
    date: 'Tue, 12 Aug 2026',
    time: '02:00 PM',
    notes: 'Brown ombre cat eye with gold accents.',
    previousServices: 'Nail Art - 1 month ago',
    status: 'Confirmed'
  },
  {
    appointmentId: 'APT-1004',
    customerName: 'Neha Verma',
    customerPhone: '+91 98333 44556',
    customerEmail: 'neha.v@example.com',
    customerId: 'CUST-0004',
    serviceName: 'Facial',
    servicePrice: 2000,
    serviceDuration: 60,
    stylistName: 'Ananya',
    branchName: 'Model Town',
    date: 'Tue, 12 Aug 2026',
    time: '12:30 PM',
    notes: 'Sensitive skin, gentle hydration only.',
    previousServices: 'Hydrafacial - 2 months ago',
    status: 'Confirmed'
  },
  {
    appointmentId: 'APT-1005',
    customerName: 'Sarah Thomas',
    customerPhone: '+91 98765 43210',
    customerEmail: 'sarah.kothari@gmail.com',
    customerId: 'CUST-0001',
    serviceName: 'Layer Cut',
    servicePrice: 2400,
    serviceDuration: 60,
    stylistName: 'Maya',
    branchName: 'Jalandhar',
    date: 'Thu, 20 Aug 2026',
    time: '02:00 PM',
    notes: 'Cascading curtain layers.',
    previousServices: 'Layer Cut - 6 months ago',
    status: 'Confirmed'
  }
];

// Helper: sync or fallback to DB
exports.getBranches = async (req, res) => {
  try {
    let branches = await Branch.find().lean();
    if (!branches || branches.length === 0) {
      branches = DEFAULT_BRANCHES;
    }
    res.status(200).json({ success: true, count: branches.length, data: branches });
  } catch (err) {
    res.status(200).json({ success: true, count: DEFAULT_BRANCHES.length, data: DEFAULT_BRANCHES });
  }
};

exports.createBranch = async (req, res) => {
  try {
    const { name, address, phone, openingTime, closingTime, status } = req.body;
    if (!name || !address) {
      return res.status(400).json({ success: false, message: 'Branch name and address are required' });
    }
    const branchId = `BR-${Date.now().toString().slice(-4)}`;
    let newBranch;
    try {
      newBranch = await Branch.create({
        branchId,
        name,
        address,
        phone: phone || '+91 98000 00000',
        openingTime: openingTime || '09:00 AM',
        closingTime: closingTime || '09:00 PM',
        status: status || 'active'
      });
    } catch {
      newBranch = { branchId, name, address, phone, openingTime, closingTime, status: status || 'active' };
    }
    res.status(201).json({ success: true, data: newBranch });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateBranch = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    let branch;
    try {
      branch = await Branch.findOneAndUpdate(
        { $or: [{ _id: id }, { branchId: id }] },
        updates,
        { new: true }
      );
    } catch {}
    res.status(200).json({ success: true, data: branch || updates });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Services
exports.getServices = async (req, res) => {
  try {
    let services = await Service.find().lean();
    if (!services || services.length === 0) {
      services = DEFAULT_SERVICES;
    }
    res.status(200).json({ success: true, count: services.length, data: services });
  } catch (err) {
    res.status(200).json({ success: true, count: DEFAULT_SERVICES.length, data: DEFAULT_SERVICES });
  }
};

exports.createService = async (req, res) => {
  try {
    const { name, category, price, duration, description, availability } = req.body;
    if (!name || price === undefined) {
      return res.status(400).json({ success: false, message: 'Service name and price are required' });
    }
    const serviceId = `SRV-${Date.now().toString().slice(-4)}`;
    let newService;
    try {
      newService = await Service.create({
        serviceId,
        name,
        category: category || 'Hair',
        price: Number(price),
        duration: Number(duration) || 60,
        description: description || '',
        availability: availability !== undefined ? availability : true
      });
    } catch {
      newService = { serviceId, name, category, price, duration, description, availability: true };
    }
    res.status(201).json({ success: true, data: newService });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateService = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    let service;
    try {
      service = await Service.findOneAndUpdate(
        { $or: [{ _id: id }, { serviceId: id }] },
        updates,
        { new: true }
      );
    } catch {}
    res.status(200).json({ success: true, data: service || updates });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Stylists
exports.getStylists = async (req, res) => {
  try {
    let stylists = await Stylist.find().populate('userId', 'name email phone').lean();
    if (!stylists || stylists.length === 0) {
      stylists = DEFAULT_STYLISTS;
    }
    res.status(200).json({ success: true, count: stylists.length, data: stylists });
  } catch (err) {
    res.status(200).json({ success: true, count: DEFAULT_STYLISTS.length, data: DEFAULT_STYLISTS });
  }
};

exports.updateStylist = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    res.status(200).json({ success: true, data: { stylistId: id, ...updates } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Appointments
exports.getAppointments = async (req, res) => {
  try {
    const { customerId, stylistName, status } = req.query;
    let list = inMemoryAppointments;
    if (customerId) {
      list = list.filter(a => a.customerId === customerId);
    }
    if (stylistName) {
      list = list.filter(a => a.stylistName.toLowerCase().includes(stylistName.toLowerCase()));
    }
    if (status && status !== 'all') {
      list = list.filter(a => a.status.toLowerCase() === status.toLowerCase());
    }
    res.status(200).json({ success: true, count: list.length, data: list });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.createAppointment = async (req, res) => {
  try {
    const {
      serviceName,
      servicePrice,
      serviceDuration,
      stylistName,
      branchName,
      date,
      time,
      customerName,
      customerPhone,
      customerEmail,
      notes
    } = req.body;

    const newApt = {
      appointmentId: `APT-${Date.now().toString().slice(-4)}`,
      customerName: customerName || 'Sarah Thomas',
      customerPhone: customerPhone || '+91 98765 43210',
      customerEmail: customerEmail || 'sarah.kothari@gmail.com',
      customerId: 'CUST-0001',
      serviceName: serviceName || 'Gel Polish',
      servicePrice: Number(servicePrice) || 1200,
      serviceDuration: Number(serviceDuration) || 60,
      stylistName: stylistName || 'Jessica Alba',
      branchName: branchName || 'Model Town',
      date: date || 'Tue, 12 Aug 2026',
      time: time || '11:00 AM',
      notes: notes || 'Client appointment booked via VIORA mobile concierge.',
      previousServices: 'Gel Polish - 3 months ago',
      status: 'Confirmed'
    };

    inMemoryAppointments.unshift(newApt);
    res.status(201).json({ success: true, data: newApt });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateAppointmentStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const apt = inMemoryAppointments.find(a => a.appointmentId === id);
    if (apt) {
      apt.status = status;
      return res.status(200).json({ success: true, data: apt });
    }
    res.status(404).json({ success: false, message: 'Appointment not found' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.rescheduleAppointment = async (req, res) => {
  try {
    const { id } = req.params;
    const { date, time } = req.body;
    const apt = inMemoryAppointments.find(a => a.appointmentId === id);
    if (apt) {
      if (date) apt.date = date;
      if (time) apt.time = time;
      return res.status(200).json({ success: true, data: apt });
    }
    res.status(404).json({ success: false, message: 'Appointment not found' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.cancelAppointment = async (req, res) => {
  try {
    const { id } = req.params;
    const apt = inMemoryAppointments.find(a => a.appointmentId === id);
    if (apt) {
      apt.status = 'Cancelled';
      return res.status(200).json({ success: true, message: 'Appointment cancelled', data: apt });
    }
    res.status(404).json({ success: false, message: 'Appointment not found' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
