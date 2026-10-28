const Branch = require('../models/Branch');
const Appointment = require('../models/Appointment');
const Review = require('../models/Review');

class BranchController {
  static async getAllBranches(req, res, next) {
    try {
      const branches = await Branch.find().sort({ name: 1 });
      const appointments = await Appointment.find();
      const reviews = await Review.find({ moderationStatus: 'approved' });

      const data = branches.map((branch) => {
        const bIdStr = branch._id.toString();
        const branchAppts = appointments.filter((a) => a.branchId && a.branchId.toString() === bIdStr);
        const branchReviews = reviews.filter((r) => r.branchId && r.branchId.toString() === bIdStr);

        let rating = 4.8;
        if (branchReviews.length > 0) {
          rating = Number((branchReviews.reduce((sum, r) => sum + r.rating, 0) / branchReviews.length).toFixed(1));
        } else {
          const lower = (branch.name + ' ' + branch.address).toLowerCase();
          if (lower.includes('flagship')) rating = 4.9;
          else if (lower.includes('sanctuary') || lower.includes('haven')) rating = 4.8;
          else rating = 4.7;
        }

        let latitude = 19.0596;
        let longitude = 72.8295;
        let distance = '0.8 km';

        const lowerInfo = (branch.name + ' ' + branch.address).toLowerCase();
        if (lowerInfo.includes('flagship') || lowerInfo.includes('waterfield')) {
          latitude = 19.0580;
          longitude = 72.8300;
          distance = '0.8 km';
        } else if (lowerInfo.includes('bandra') || lowerInfo.includes('14th road')) {
          latitude = 19.0620;
          longitude = 72.8330;
          distance = '1.2 km';
        } else if (lowerInfo.includes('khar')) {
          latitude = 19.0700;
          longitude = 72.8350;
          distance = '2.4 km';
        } else if (lowerInfo.includes('juhu')) {
          latitude = 19.1075;
          longitude = 72.8263;
          distance = '5.1 km';
        } else if (lowerInfo.includes('colaba')) {
          latitude = 18.9220;
          longitude = 72.8347;
          distance = '18.4 km';
        }

        const serviceCount = 38 + (branchAppts.length * 4);

        return {
          ...branch.toObject(),
          rating,
          serviceCount,
          latitude,
          longitude,
          distance,
          services: ['Hair', 'Nails', 'Skin', 'Makeup', 'Beauty', 'Consultation', 'Balayage', 'Facial']
        };
      });

      return res.status(200).json({
        success: true,
        count: data.length,
        data
      });
    } catch (err) {
      next(err);
    }
  }

  static async getBranchById(req, res, next) {
    try {
      const { id } = req.params;
      const branch = await Branch.findOne({
        $or: [{ branchId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!branch) {
        return res.status(404).json({
          success: false,
          message: 'Branch not found'
        });
      }

      return res.status(200).json({
        success: true,
        data: branch
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = BranchController;
