require "spec_helper"

RSpec.describe "a control test without wrapping" do
  it { expect(true).to be(false) }

  after { RSpec.current_example.metadata[:extra_failure_lines] = "foo\nbar" }
end
