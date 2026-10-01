module DevelopmentReports
  class SubmitForReview
    def self.call(report:, user:)
      new(report:, user:).call
    end

    def initialize(report:, user:)
      @report = report
      @user = user
    end

    def call
      raise ArgumentError, "Only Developer users can submit reports" unless @user.developer?

      @report.with_lock do
        raise ArgumentError, "Report is not editable" unless @report.editable?

        @report.update!(
          status: :under_review,
          submitted_by: @user,
          submitted_at: Time.current,
          review_comment: nil,
          reviewed_by: nil,
          reviewed_at: nil,
          approved_at: nil
        )

        AuditLogger.call(
          user: @user,
          auditable: @report,
          action: "submitted_for_review"
        )
      end

      @report
    end
  end
end
