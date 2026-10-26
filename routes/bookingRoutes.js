const express = require('express');
const router = express.Router();
const {
  getBranches,
  createBranch,
  updateBranch,
  getServices,
  createService,
  updateService,
  getStylists,
  updateStylist,
  getAppointments,
  createAppointment,
  updateAppointmentStatus,
  rescheduleAppointment,
  cancelAppointment
} = require('../controllers/bookingController');

// Branch routes
router.route('/branches')
  .get(getBranches)
  .post(createBranch);

router.route('/branches/:id')
  .put(updateBranch);

// Service routes
router.route('/services')
  .get(getServices)
  .post(createService);

router.route('/services/:id')
  .put(updateService);

// Stylist routes
router.route('/stylists')
  .get(getStylists);

router.route('/stylists/:id')
  .put(updateStylist);

// Appointment routes
router.route('/appointments')
  .get(getAppointments)
  .post(createAppointment);

router.route('/appointments/:id/status')
  .put(updateAppointmentStatus);

router.route('/appointments/:id/reschedule')
  .put(rescheduleAppointment);

router.route('/appointments/:id/cancel')
  .put(cancelAppointment);

router.route('/appointments/:id')
  .delete(cancelAppointment);

module.exports = router;
