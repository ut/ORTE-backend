# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/relations', type: :request do
  before do
    group = FactoryBot.create(:group)
    @user = FactoryBot.create(:user, group: group)
    sign_in @user

    @map = create(:map, group: group)
    layer = create(:layer, map: @map)
    another_layer = create(:layer, map: @map)
    @layers = [layer, another_layer]
    @p1 = create(:place, layer: layer)
    @p2 = create(:place, layer: layer)
    @relation = create(:relation, relation_from_id: @p1.id, relation_to_id: @p2.id)
  end

  # Relation. As you add validations to Relation, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    FactoryBot.build(:relation, relation_from_id: @p1.id, relation_to_id: @p2.id).attributes
  end

  let(:invalid_attributes) do
    FactoryBot.attributes_for(:relation, :invalid)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Relation.create! valid_attributes
      get map_relations_url(@map)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_map_relation_url(@map)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      relation = Relation.create! valid_attributes
      get edit_map_relation_url(@map, relation)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Relation' do
        expect do
          post map_relations_url(@map), params: { relation: valid_attributes }
        end.to change(Relation, :count).by(1)
      end

      it 'redirects to the created relation' do
        post map_relations_url(@map), params: { relation: valid_attributes }
        expect(response).to redirect_to(map_relations_url(@map))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Relation' do
        expect do
          post map_relations_url(@map), params: { relation: invalid_attributes }
        end.to change(Relation, :count).by(0)
      end

      xit "renders a successful response (i.e. to display the 'new' template)" do
        post map_relations_url(@map), params: { relation: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        FactoryBot.attributes_for(:relation, :changed, relation_from_id: @p1.id, relation_to_id: @p2.id)
      end

      it 'updates the requested relation' do
        relation = Relation.create! valid_attributes
        patch map_relation_url(@map, relation), params: { relation: new_attributes }
        relation.reload
        expect(relation.rtype).to eq('sequence')
      end

      it 'redirects to the relation' do
        relation = Relation.create! valid_attributes
        patch map_relation_url(@map, relation), params: { relation: new_attributes }
        relation.reload
        expect(response).to redirect_to(map_relations_url(@map))
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        relation = Relation.create! valid_attributes
        patch map_relation_url(@map, relation), params: { relation: invalid_attributes }
        expect(response).not_to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested relation' do
      relation = Relation.create! valid_attributes
      expect do
        delete map_relation_url(@map, relation)
      end.to change(Relation, :count).by(-1)
    end

    it 'redirects to the relations list' do
      relation = Relation.create! valid_attributes
      delete map_relation_url(@map, relation)
      expect(response).to redirect_to(map_relations_url(@map))
    end
  end
end
