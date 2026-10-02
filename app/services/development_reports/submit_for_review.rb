module DevelopmentReports
  class SubmitForReview
    def self.call(report:, user:, attributes: {})
      new(report:, user:, attributes:).call
    end

    def initialize(report:, user:, attributes:)
      @report = report
      @user = user
      @attributes = attributes
    end

    def call
      raise ArgumentError, "Only Developer users can submit reports" unless @user.developer?

      @report.with_lock do
        raise ArgumentError, "Report is not editable" unless @report.editable?

        # Save nested items while the report is editable. The surrounding lock
        # transaction rolls back both changes if submission fails.
        if @attributes.present?
          @report.update!(@attributes)
          AuditLogger.call(user: @user, auditable: @report, action: "draft_updated")
        end

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
