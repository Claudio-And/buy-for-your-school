RSpec.feature "Tasks" do
  let(:user) { create(:user) }
  let(:fixture) { "task-with-multiple-steps.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when a task has a single question and the user answers it" do
    let(:fixture) { "long-text-question.json" }

    scenario "the user is returned to the same place in the task list " do
      click_first_link_in_section_list
      # TODO: replace
      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_continue

      # TODO: replace
      answer = LongTextAnswer.last

      # TODO: pattern for anchors
      expect(page).to have_current_path(journey_url(journey, anchor: answer.step.id))
    end
  end

  context "when a task has more than 1 question" do
    scenario "the user is taken straight to the next question" do
      click_first_link_in_section_list

      journey = Journey.last
      task = journey.sections.first.tasks.first

      within("div.govuk-radios__item", match: :first) do
        choose "Catering"
      end

      click_continue

      within("div.govuk-form-group") do
        fill_in "answer[response]", with: "This is my short answer"
      end

      click_continue

      within("div.govuk-form-group") do
        fill_in "answer[response]", with: "This is my long answer"
      end

      click_continue

      within("div.govuk-form-group") do
        check("Breakfast")
      end

      click_continue

      expect(find("h1.govuk-heading-xl")).to have_text "Task with multiple steps"
      # /journeys/302e58f4-01b3-469a-906e-db6991184699/tasks/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path "/journeys/#{journey.id}/tasks/#{task.id}"
    end
  end

  context "when a task that has no answers is opened" do
    scenario "takes the user straight to the first question" do
      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      expect(page).not_to have_content("Task with multiple steps")
      expect(find("label.govuk-radios__label", match: :first)).to have_text "Catering"
    end
  end
end
