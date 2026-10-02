# Search and paginate the authorized scope before fetching any records.
class ReportListing
  SORT_COLUMNS = {
    "report_date" => "development_reports.report_date", "status" => "development_reports.status",
    "submitted_by" => "users.name", "updated_at" => "development_reports.updated_at",
    "reporting_month" => "development_reports.reporting_month", "approved_at" => "development_reports.approved_at",
    "reviewed_at" => "development_reports.reviewed_at"
  }.freeze
  attr_reader :records, :query, :page, :per_page, :total, :pages, :prefix, :sort, :direction

  def initialize(scope, params, prefix: "")
    @prefix = prefix
    @query = params[key(:q)].to_s.strip.first(100)
    @per_page = params[key(:per_page)].to_i
    @per_page = 10 unless [ 10, 25, 50, 100 ].include?(@per_page)
    if query.present?
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope = scope.left_joins(:submitted_by).where(
        "users.name ILIKE :q OR to_char(development_reports.report_date, 'DD-MM-YYYY') ILIKE :q OR to_char(development_reports.reporting_month, 'FMMonth YYYY') ILIKE :q", q: pattern
      ).or(scope.left_joins(:submitted_by).where(status: DevelopmentReport.statuses.keys.select { |status| status.tr("_", " ").include?(query.downcase) }))
    end
    @sort = SORT_COLUMNS.key?(params[key(:sort)]) ? params[key(:sort)] : "report_date"
    @direction = params[key(:direction)] == "asc" ? "asc" : "desc"
    @total = scope.count
    scope = scope.left_joins(:submitted_by) if sort == "submitted_by"
    table_name, column_name = SORT_COLUMNS.fetch(sort).split(".")
    column = Arel::Table.new(table_name)[column_name]
    id = DevelopmentReport.arel_table[:id]
    order = direction == "asc" ? column.asc : column.desc
    tie_breaker = direction == "asc" ? id.asc : id.desc
    scope = scope.reorder(order.nulls_last, tie_breaker)
    @pages = [ (total.to_f / per_page).ceil, 1 ].max
    @page = params[key(:page)].to_i.clamp(1, pages)
    @records = scope.includes(:submitted_by).offset(offset).limit(per_page)
  end

  def key(name)
    "#{prefix}#{name}"
  end

  def offset
    (page - 1) * per_page
  end
end
