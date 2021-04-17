# frozen_string_literal: true

require 'spec_helper'

describe Zoom::Actions::Meeting do
  let(:zc) { zoom_client }
  let(:args) { { meeting_id: '123456789' } }

  describe '#ended_meeting_instances' do
    context 'with a valid response' do
      before :each do
        stub_request(
          :get,
          zoom_url("/past_meetings/#{args[:meeting_id]}/instances")
        ).to_return(status: 200,
                    body: json_response('meeting', 'ended_instances'),
                    headers: { 'Content-Type' => 'application/json' })
      end

      it "requires a 'id' argument" do
        expect { zc.ended_meeting_instances(filter_key(args, :meeting_id)) }.to raise_error(Zoom::ParameterMissing, [:meeting_id].to_s)
      end

      it 'returns a list of ended meeting instances as an array' do
        expect(zc.ended_meeting_instances(args)['meetings']).to be_kind_of(Array)
      end
    end

    context 'with a 4xx response' do
      before :each do
        stub_request(
          :get,
          zoom_url("/past_meetings/#{args[:meeting_id]}/instances")
        ).to_return(status: 404,
                    body: json_response('error', 'validation'),
                    headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises Zoom::Error exception' do
        expect { zc.ended_meeting_instances(args) }.to raise_error(Zoom::Error)
      end
    end
  end
end
