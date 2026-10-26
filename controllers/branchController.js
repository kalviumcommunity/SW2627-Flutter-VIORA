const Branch = require('../models/Branch');

class BranchController {
  static async getAllBranches(req, res, next) {
    try {
      const branches = await Branch.find().sort({ name: 1 });
      return res.status(200).json({
        success: true,
        count: branches.length,
        data: branches
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
