require "test_helper"
require "zip"

class DevelopmentReports::ExcelExporterTest < ActiveSupport::TestCase
  setup do
    @report = DevelopmentReports::CreateDraft.call(project: projects(:sapphire), user: users(:submitter),
      reporting_month: Date.new(2026, 9, 1), report_date: Date.new(2026, 9, 14))
    items = @report.items.to_a
    items[0].update!(completion_percentage: 34.25, expected_completion_on: Date.new(2026, 10, 17),
      delay_reason: "Waiting for materials", support_required: "=SUM(1,2)")
    items[1].update!(completion_percentage: 100)
    items[2].update!(completion_percentage: 0)
    @files = {}
    Zip::File.open_buffer(DevelopmentReports::ExcelExporter.new(@report).to_stream) do |zip|
      zip.each { |entry| @files[entry.name] = Nokogiri::XML(entry.get_input_stream.read).remove_namespaces! if entry.name.end_with?(".xml") }
    end
    @sheet = @files.fetch("xl/worksheets/sheet1.xml")
    @strings = @files.fetch("xl/sharedStrings.xml").xpath("//si").map(&:text)
  end

  test "exports the reference report layout with all categories in their saved order" do
    assert_equal DevelopmentReports::ExcelExporter::TITLE, text("A1")
    assert_equal "A1:F1", @sheet.at_xpath("//mergeCell")["ref"]
    assert_equal "Description", text("B2")
    assert_equal "Percentage Completion\nby 14-09-2026", text("C2")
    assert_equal 14, @sheet.xpath("//sheetData/row").length
    @report.items.each_with_index do |item, index|
      assert_equal item.development_category.name, text("B#{index + 3}")
      assert_equal (index + 1).to_s, value("A#{index + 3}")
    end
    assert_equal "2", @sheet.at_xpath("//pane")["ySplit"]
    assert_equal "landscape", @sheet.at_xpath("//pageSetup")["orientation"]
  end

  test "preserves numeric percentages dates and genuinely blank values" do
    assert_in_delta 0.3425, value("C3").to_f, 0.000001
    assert_equal "1.0", value("C4")
    assert_equal "0.0", value("C5")
    assert_nil value("C6")
    assert_nil value("D4")
    assert_equal (Date.new(2026, 10, 17) - Date.new(1899, 12, 30)).to_i, value("D3").to_f.to_i
    assert_equal "Waiting for materials", text("E3")
    assert_equal "=SUM(1,2)", text("F3")
    assert_empty @sheet.xpath("//f"), "User text must not become an Excel formula"
    formats = @files.fetch("xl/styles.xml").xpath("//numFmt").map { |format| format["formatCode"] }
    assert_includes formats, "0.##%"
    assert_includes formats, "dd-mm-yyyy"
  end

  test "uses the blue title and serial column and alternating body backgrounds" do
    assert_equal "FF4472C4", fill("A1")
    assert_equal "FF4472C4", fill("A3")
    assert_equal "FFE9EBF5", fill("B3")
    assert_equal "FFCFD5EA", fill("B4")
    assert_equal fill("B3"), fill("B5")
  end

  private

  def value(reference)
    @sheet.at_xpath("//c[@r='#{reference}']/v")&.text
  end

  def text(reference)
    @strings.fetch(value(reference).to_i)
  end

  def fill(reference)
    styles = @files.fetch("xl/styles.xml")
    style = styles.xpath("//cellXfs/xf")[@sheet.at_xpath("//c[@r='#{reference}']")["s"].to_i]
    styles.xpath("//fills/fill")[style["fillId"].to_i].at_xpath(".//fgColor")["rgb"]
  end
end
