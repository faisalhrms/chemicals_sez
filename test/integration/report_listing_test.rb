require "test_helper"

class ReportListingTest < ActionDispatch::IntegrationTest
  setup do
    26.times do |index|
      DevelopmentReport.create!(project: projects(:sapphire), created_by: users(:submitter),
        reporting_month: Date.new(2026, 9, 1), report_date: Date.new(2026, 9, index + 1))
    end
    post session_path, params: { email_address: users(:submitter).email_address,
      password: "StrongPassword!123", workspace: "developer" }
  end

  test "report list paginates and searches before rendering" do
    get developer_development_reports_path, params: { month: "2026-09" }
    assert_response :success
    assert_select "tbody tr", count: 10
    assert_select "a", text: "Next"
    get developer_development_reports_path, params: { month: "2026-09", page: 3 }
    assert_response :success
    assert_select "tbody tr", count: 6
    assert_select "tbody tr:first-child td:first-child", text: "21"
    get developer_development_reports_path, params: { month: "2026-09", q: "26-09-2026" }
    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody td", text: "26-09-2026"
  end

  test "sorting stays on the server and rejects unrecognized columns" do
    get developer_development_reports_path, params: { month: "2026-09", sort: "report_date", direction: "asc" }
    assert_response :success
    assert_select "tbody tr:first-child td:nth-child(2)", text: "01-09-2026"
    listing = ReportListing.new(DevelopmentReport.all, { "sort" => "invalid SQL", "direction" => "invalid" })
    assert_equal "report_date", listing.sort
    assert_equal "desc", listing.direction
  end

  test "page sizes are bounded and out of range pages are clamped" do
    listing = ReportListing.new(DevelopmentReport.all.latest_first, { "per_page" => "100000", "page" => "9999" })
    assert_equal 10, listing.per_page
    assert_equal listing.pages, listing.page
    assert_operator listing.records.length, :<=, 10
  end

  test "authority pagination preserves authorized scope" do
    post session_path, params: { email_address: users(:authority).email_address,
      password: "StrongPassword!123", workspace: "authority" }
    get authority_development_reports_path, params: { month: "2026-09", q: "Draft" }
    assert_response :success
    assert_select ".datatable-info", text: "Showing 0–0 of 0 records"
  end
end
