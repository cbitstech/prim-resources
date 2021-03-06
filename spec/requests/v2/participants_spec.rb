require 'rails_helper'

RSpec.describe 'Participants resource', type: :request do
  include_examples 'requests'

  fixtures :all

  let(:last_participant) { Participant.last }

  describe 'GET /v2/participants' do
    context 'for a consumer scoped to a single project' do
      it 'sends the participants in that project' do
        get '/v2/participants', nil, single_project_auth_header

        expect(response).to be_success
        expect(json['participants'].length)
          .to be Project.first.participants.count
      end
    end

    context 'for a consumer scoped to all projects' do
      it 'sends all participants' do
        get '/v2/participants', nil, all_project_auth_header

        expect(response).to be_success
        expect(json['participants'].length).to be Participant.count
      end
    end
  end

  describe 'GET /v2/participants filtered' do
    it 'sends Participants with matching emails' do
      e = emails(:participant_12)
      get "/v2/participants?participants.emails.email.eq=#{ e.email }", nil,
          all_project_auth_header

      expect(response).to be_success
      expect(json['participants'].length).to be 1
      expect(json['participants'][0]['id']).to eq e.participant.external_id
    end

    it 'sends Participants with matching birth dates' do
      b = date_of_births(:participant_79)
      get "/v2/participants?participants.date_of_birth.date.eq=#{ b.date }",
          nil,
          all_project_auth_header

      expect(response).to be_success
      expect(json['participants'].length).to be 1
      expect(json['participants'][0]['id']).to eq b.participant.external_id
    end
  end

  describe 'GET /v2/participants/:id' do
    context 'when the participant is found' do
      let(:participant) { Project.first.participants.first }

      it 'sends the participant' do
        get "/v2/participants/#{ participant.external_id }",
            nil,
            all_project_auth_header

        expect(response).to be_success
        expect(json['participants']['id']).to eq participant.external_id
      end
    end

    context 'when the participant is not found anywhere' do
      it 'sends an error' do
        get '/v2/participants/baz', nil, all_project_auth_header

        expect(response).to be_not_found
        expect(json['errors']).not_to be_nil
      end
    end

    context 'when the participant is not found in a project' do
      it 'sends an error' do
        get "/v2/participants/#{ participants(:participant_0).external_id }",
            nil,
            single_project_auth_header

        expect(response).to be_not_found
        expect(json['errors']).not_to be_nil
      end
    end
  end

  describe 'POST /v2/participants' do
    context 'for a consumer scoped to a single project' do
      it 'creates a participant associated with the project' do
        participant = { participants: {
          date_of_birth: { date: '1924-12-05' }
        } }
        expect do
          post '/v2/participants', participant, single_project_auth_header
        end.to change { Project.first.participants.count }.by 1

        expect(response.status).to be 201
        expect(json['participants']).not_to be_nil
      end
    end

    context 'for a consumer scoped to all projects' do
      it 'creates a participant' do
        participant = {
          participants: {
            date_of_birth: { date: '2000-01-01' }
          }
        }
        expect do
          post '/v2/participants', participant, all_project_auth_header
        end.to change { Participant.count }.by 1

        expect(response.status).to be 201
        expect(json['participants']).not_to be_nil
      end
    end
  end

  describe 'PUT /v2/participants/:id' do
    context 'when the participant is found' do
      context 'when the update is successful' do
        it 'reponds with success' do
          participant_mod = {}
          put "/v2/participants/#{ last_participant.external_id }",
              participant_mod,
              all_project_auth_header

          expect(response.status).to be 200
          expect(json['participants']).not_to be_nil
        end
      end

      context 'when the update is unsuccessful' do
        it 'responds with bad request' do
          expect_any_instance_of(Participant).to receive(:update) { false }
          put "/v2/participants/#{ last_participant.external_id }",
              {},
              all_project_auth_header

          expect(response.status).to be 400
          expect(json['errors']).not_to be_nil
        end
      end
    end

    context 'when the participant is not found' do
      it 'responds with an error' do
        put '/v2/participants/baz',
            {},
            all_project_auth_header

        expect(response.status).to be 404
        expect(json['errors']).not_to be_nil
      end
    end
  end

  describe 'DELETE /v2/participants/:id' do
    context 'when the participant is found' do
      context 'when the deletion is successful' do
        it 'reponds with no content' do
          delete "/v2/participants/#{ last_participant.external_id }",
                 {},
                 all_project_auth_header

          expect(response.status).to be 204
        end
      end

      context 'when the deletion is not successful' do
        it 'responds with bad request' do
          expect_any_instance_of(Participant).to receive(:destroy) { false }
          delete "/v2/participants/#{ last_participant.external_id }",
                 {},
                 all_project_auth_header

          expect(json['errors']).not_to be_nil
          expect(response.status).to be 400
        end
      end
    end

    context 'when the participant is not found' do
      it 'responds with not found' do
        delete '/v2/participants/baz', {}, all_project_auth_header

        expect(json['errors']).not_to be_nil
        expect(response.status).to be 404
      end
    end
  end
end
