require "spec_helper"

RSpec.describe "Integration with RSpec's #include matcher", type: :integration do
  context "assuming color is enabled" do
    context "when used against an array" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = ["Marty", "Einie"]
            actual = ["Marty", "Jennifer", "Doc"]
            expect(actual).to include(*expected)
          TEST

          expected_output = build_colored_expected_output(
            snippet: %|expect(actual).to include(*expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["Marty", "Jennifer", "Doc"]|
                plain " to include "
                red   %|"Einie"|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "Marty",|
              plain_line %|    "Jennifer",|
              # plain_line %|    "Doc",|   # FIXME
              plain_line %|    "Doc"|
              red_line   %|-   "Einie"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Biff Tannen",
              "George McFly",
              "Lorraine McFly"
            ]
            actual = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(actual).to include(*expected)
          TEST

          expected_output = build_colored_expected_output(
            snippet: %|expect(actual).to include(*expected)|,
            expectation: proc {
              line do
                plain "  Expected "
                green %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain "to include "
                red %|"Biff Tannen" and "George McFly"|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "Marty McFly",|
              plain_line %|    "Doc Brown",|
              plain_line %|    "Einie",|
              # plain_line %|    "Lorraine McFly",|   # FIXME
              plain_line %|    "Lorraine McFly"|
              red_line   %|-   "Biff Tannen",|
              red_line   %|-   "George McFly"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when used against a hash" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = { city: "Hill Valley", state: "CA" }
            actual = { city: "Burbank", zip: "90210" }
            expect(actual).to include(expected)
          TEST

          expected_output = build_colored_expected_output(
            snippet: %|expect(actual).to include(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ city: "Burbank", zip: "90210" }|
                plain " to include "
                red %|(city: "Hill Valley", state: "CA")|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  {|
              red_line   %|-   city: "Hill Valley",|
              green_line %|+   city: "Burbank",|
              # FIXME
              # plain_line %|    zip: "90210",|
              plain_line %|    zip: "90210"|
              red_line   %|-   state: "CA"|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              city: "Hill Valley",
              zip: "90382"
            }
            actual = {
              city: "Burbank",
              state: "CA",
              zip: "90210"
            }
            expect(actual).to include(expected)
          TEST

          expected_output = build_colored_expected_output(
            snippet: %|expect(actual).to include(expected)|,
            expectation: proc {
              line do
                plain "  Expected "
                green %|{ city: "Burbank", state: "CA", zip: "90210" }|
              end

              line do
                plain "to include "
                red %|(city: "Hill Valley", zip: "90382")|
              end
            },
            diff: proc {
              plain_line %|  {|
              red_line   %|-   city: "Hill Valley",|
              green_line %|+   city: "Burbank",|
              plain_line %|    state: "CA",|
              red_line   %|-   zip: "90382"|
              green_line %|+   zip: "90210"|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end
  end

  context "if color has been disabled" do
    it "does not include the color in the output" do
      program = make_plain_test_program(<<~TEST, color_enabled: false)
        expected = ["Marty", "Einie"]
        actual = ["Marty", "Jennifer", "Doc"]
        expect(actual).to include(*expected)
      TEST

      expected_output = build_uncolored_expected_output(
        snippet: %|expect(actual).to include(*expected)|,
        expectation: proc {
          line do
            plain "Expected "
            plain %|["Marty", "Jennifer", "Doc"]|
            plain " to include "
            plain %|"Einie"|
            plain "."
          end
        },
        diff: proc {
          plain_line %|  [|
          plain_line %|    "Marty",|
          plain_line %|    "Jennifer",|
          # plain_line %|    "Doc",|   # FIXME
          plain_line %|    "Doc"|
          plain_line %|-   "Einie"|
          plain_line %|  ]|
        },
      )

      expect(program).to produce_output_when_run(expected_output)
    end
  end
end