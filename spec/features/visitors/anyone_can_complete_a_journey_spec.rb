require "rails_helper"

feature "Anyone can start a journey" do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
    ) do
      example.run
    end
  end

  scenario "Start page includes a call to action" do
    stub_get_contentful_entries(
      entry_id: "contentful-starting-step",
      fixture_filename: "closed-path-with-multiple-example.json"
    )

    visit root_path

    click_on(I18n.t("generic.button.start"))

    expect(page).to have_content("Catering")
    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Not started")
  end

  scenario "an answer must be provided" do
    stub_get_contentful_entries(
      entry_id: "contentful-starting-step",
      fixture_filename: "closed-path-with-multiple-example.json"
    )
    journey = CreateJourney.new(category: "catering").call
    step = journey.steps.find_by(contentful_id: "contentful-radio-question")

    visit journey_step_path(journey, step)

    # Omit a choice

    click_on(I18n.t("generic.button.next"))

    expect(page).to have_content("can't be blank")
  end

  context "when the Contentful model is of type question" do
    context "when Contentful entry is of type short_text" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      scenario "user can answer using free text" do
        stub_get_contentful_entries(
          entry_id: "contentful-starting-step",
          fixture_filename: "closed-path-with-multiple-example.json"
        )
        journey = CreateJourney.new(category: "catering").call
        step = journey.steps.find_by(contentful_id: "contentful-short-text-question")

        visit journey_step_path(journey, step)

        fill_in "answer[response]", with: "email@example.com"
        click_on(I18n.t("generic.button.next"))

        click_on(step.title)

        expect(find_field("answer-response-field").value).to eql("email@example.com")
      end
    end

    context "when Contentful entry is of type long_text" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      scenario "user can answer using free text with multiple lines" do
        stub_get_contentful_entries(
          entry_id: "contentful-starting-step",
          fixture_filename: "closed-path-with-multiple-example.json"
        )
        journey = CreateJourney.new(category: "catering").call
        step = journey.steps.find_by(contentful_id: "contentful-long-text-question")

        visit journey_step_path(journey, step)

        fill_in "answer[response]", with: "We would like a supplier to provide catering from September 2020.\nThey must be able to supply us for 3 years minumum."
        click_on(I18n.t("generic.button.next"))

        click_on(step.title)

        expect(find_field("answer-response-field").value).to eql("We would like a supplier to provide catering from September 2020.\r\nThey must be able to supply us for 3 years minumum.")
      end
    end

    context "when Contentful entry is of type single_date" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      scenario "user can answer using a date input" do
        stub_get_contentful_entries(
          entry_id: "contentful-starting-step",
          fixture_filename: "closed-path-with-multiple-example.json"
        )
        journey = CreateJourney.new(category: "catering").call
        step = journey.steps.find_by(contentful_id: "contentful-single-date-question")

        visit journey_step_path(journey, step)

        fill_in "answer[response(3i)]", with: "12"
        fill_in "answer[response(2i)]", with: "8"
        fill_in "answer[response(1i)]", with: "2020"

        click_on(I18n.t("generic.button.next"))

        click_on(step.title)

        expect(find_field("answer_response_3i").value).to eql("12")
        expect(find_field("answer_response_2i").value).to eql("8")
        expect(find_field("answer_response_1i").value).to eql("2020")
      end
    end

    context "when Contentful entry is of type checkboxes" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      scenario "user can select multiple answers" do
        stub_get_contentful_entries(
          entry_id: "contentful-starting-step",
          fixture_filename: "closed-path-with-multiple-example.json"
        )
        journey = CreateJourney.new(category: "catering").call
        step = journey.steps.find_by(contentful_id: "contentful-checkboxes-question")

        visit journey_step_path(journey, step)

        check "Breakfast"
        check "Lunch"

        click_on(I18n.t("generic.button.next"))

        click_on(step.title)

        expect(page).to have_checked_field("answer-response-breakfast-field")
        expect(page).to have_checked_field("answer-response-lunch-field")
      end
    end

    context "when Contentful entry is of type radios" do
      context "when extra configuration is passed to collect further info" do
        around do |example|
          ClimateControl.modify(
            CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
          ) do
            example.run
          end
        end

        scenario "asks the user for further information" do
          stub_get_contentful_entries(
            entry_id: "contentful-starting-step",
            fixture_filename: "closed-path-with-multiple-example.json"
          )
          journey = CreateJourney.new(category: "catering").call
          step = journey.steps.find_by(contentful_id: "contentful-radio-question")

          visit journey_step_path(journey, step)

          click_on(I18n.t("generic.button.start"))

          choose("Catering")
          fill_in "answer[further_information]", with: "The school needs the kitchen cleaned once a day"

          click_on(I18n.t("generic.button.next"))

          click_on(step.title)

          expect(page).to have_checked_field("Catering")
          expect(find_field("answer-further-information-field").value)
            .to eql("The school needs the kitchen cleaned once a day")
        end
      end
    end
  end

  context "when the Contentful model is of type staticContent" do
    context "when Contentful entry is of type paragraphs" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
        ) do
          example.run
        end
      end

      scenario "user can read static content and proceed without answering" do
        stub_get_contentful_entries(
          entry_id: "contentful-starting-step",
          fixture_filename: "closed-path-with-multiple-example.json"
        )
        journey = CreateJourney.new(category: "catering").call
        step = journey.steps.find_by(contentful_id: "contentful-starting-step")

        visit journey_step_path(journey, step)

        expect(page).to have_content("When you should start")

        within(".static-content") do
          paragraphs_elements = find_all("p")
          expect(paragraphs_elements.first.text).to have_content("Procuring a new catering contract can take up to 6 months to consult, create, review and award.")
          expect(paragraphs_elements.last.text).to have_content("Usually existing contracts start and end in the month of September. We recommend starting this process around March.")
        end

        click_on(I18n.t("generic.button.next"))

        expect(page).to have_content("Catering")
      end
    end
  end

  context "when Contentful entry model wasn't an expected type" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-unexpected-model"
      ) do
        example.run
      end
    end

    scenario "returns an error message" do
      stub_get_contentful_entries(
        entry_id: "contentful-unexpected-model",
        fixture_filename: "path-with-unexpected-model.json"
      )

      visit new_journey_path

      expect(page).to have_content(I18n.t("errors.unexpected_contentful_model.page_title"))
      expect(page).to have_content(I18n.t("errors.unexpected_contentful_model.page_body"))
    end
  end

  context "when the Contentful Entry wasn't an expected step type" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-unexpected-step-type-category"
      ) do
        example.run
      end
    end

    scenario "returns an error message" do
      # stub_get_contentful_entries(
      #   fixture_filename: "path-with-unexpected-step-type.json"
      # )
      # stub_get_contentful_entry(
      #   entry_id: "contentful-unexpected-step-type-category",
      #   fixture_filename: "categories/unexpected-step-example.json"
      # )

      # Stub getting the category
      contentful_connector = instance_double(ContentfulConnector)
      expect(ContentfulConnector).to receive(:new)
        .and_return(contentful_connector)
      contentful_response = fake_contentful_entry(contentful_fixture_filename: "categories/unexpected-step-example.json")
      allow(contentful_connector).to receive(:get_entry_by_id)
        .with("contentful-unexpected-step-type-category")
        .and_return(contentful_response)

      # Stub getting all steps
      raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/path-with-unexpected-step-type.json")
      contentful_connector = instance_double(ContentfulConnector)
      contentful_response = fake_contentful_entry_array(contentful_fixture_filename: "path-with-unexpected-step-type.json")
      allow(contentful_connector).to receive(:get_all_entries)
        .and_return(contentful_response)
      allow(contentful_response).to receive(:raw)
        .and_return(raw_response)

      visit new_journey_path

      expect(page).to have_content(I18n.t("errors.unexpected_contentful_step_type.page_title"))
      expect(page).to have_content(I18n.t("errors.unexpected_contentful_step_type.page_body"))
    end
  end

  context "when the starting entry id doesn't exist" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-fake-entry-id"
      ) do
        example.run
      end
    end

    scenario "a Contentful entry_id does not exist" do
      stub_get_contentful_entries(
        entry_id: "contentful-fake-entry-id",
        fixture_filename: "closed-path-with-multiple-example.json"
      )

      visit new_journey_path

      expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_title"))
      expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_body"))
    end
  end

  context "when the Liquid template was invalid" do
    it "raises an error" do
      fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/invalid.liquid")
      allow_any_instance_of(FindLiquidTemplate).to receive(:file).and_return(fake_liquid_template)

      visit root_path

      click_on(I18n.t("generic.button.start"))

      expect(page).to have_content(I18n.t("errors.specification_template_invalid.page_title"))
      expect(page).to have_content(I18n.t("errors.specification_template_invalid.page_body"))
    end
  end
end
