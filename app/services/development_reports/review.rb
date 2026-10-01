module DevelopmentReports
  class Review
    DECISIONS = %w[approve revert].freeze

    def self.call(report:, reviewer:, decision:, comment: nil)
      new(report:, reviewer:, decision:, comment:).call
    end

    def initialize(report:, reviewer:, decision:, comment:)
      @report = report
      @reviewer = reviewer
      @decision = decision.to_s
      @comment = comment.to_s.strip
    end

    def call
      raise ArgumentError, "Invalid decision" unless DECISIONS.include?(@decision)
      raise ArgumentError, "Only reviewers can review reports" unless @reviewer.reviewer?
      raise ArgumentError, "A comment is required when reverting" if @decision == "revert" && @comment.blank?

      @report.with_lock do
        validate_locked_report!
        @decision == "approve" ? approve! : revert!
      end

      @report
    end

    private

    def validate_locked_report!
      raise ArgumentError, "You cannot review your own submission" if @report.submitted_by_id == @reviewer.id
      raise ArgumentError, "Report is not under review" unless @report.under_review?
    end

    def approve!
      @report.update!(
        status: :approved,
        reviewed_by: @reviewer,
        reviewed_at: Time.current,
        approved_at: Time.current,
        review_comment: @comment.presence
      )
      AuditLogger.call(
        user: @reviewer,
        auditable: @report,
        action: "approved",
        metadata: { comment: @comment.presence }
      )
    end

    def revert!
      @report.update!(
        status: :reverted,
        reviewed_by: @reviewer,
        reviewed_at: Time.current,
        review_comment: @comment,
        approved_at: nil
      )
      AuditLogger.call(
        user: @reviewer,
        auditable: @report,
        action: "reverted",
        metadata: { comment: @comment }
      )
    end
  end
end
