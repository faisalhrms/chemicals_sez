module DevelopmentReports
  class CreateDraft
    def self.call(project:, user:, reporting_month:, report_date:)
      new(project:, user:, reporting_month:, report_date:).call
    end

    def initialize(project:, user:, reporting_month:, report_date:)
      @project = project
      @user = user
      @reporting_month = reporting_month.beginning_of_month
      @report_date = report_date
    end

    def call
      DevelopmentReport.transaction do
        source = latest_approved_report
        report = @project.development_reports.create!(
          reporting_month: @reporting_month,
          report_date: @report_date,
          source_report: source,
          created_by: @user
        )

        build_items(report, source)
        AuditLogger.call(
          user: @user,
          auditable: report,
          action: "draft_created",
          metadata: { source_report_id: source&.id }
        )

        report
      end
    end

    private

    def latest_approved_report
      @project.development_reports
        .approved
        .where("report_date <= ?", @report_date)
        .latest_first
        .first
    end

    def build_items(report, source)
      source_items = source&.items&.index_by(&:development_category_id) || {}

      DevelopmentCategory.active_ordered.each do |category|
        previous = source_items[category.id]
        report.items.create!(
          development_category: category,
          completion_percentage: previous&.completion_percentage,
          expected_completion_on: previous&.expected_completion_on,
          delay_reason: previous&.delay_reason,
          support_required: previous&.support_required
        )
      end
    end
  end
end
