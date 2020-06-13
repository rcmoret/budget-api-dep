# frozen_string_literal: true

module API
  class Icons < Base
    register Sinatra::Namespace

    get %r{/?} do
      render_collection(icons)
    end

    post %r{/?} do
      create_icon!
      render_new(icon)
    end

    namespace %r{/(?<icon_id>\d+)} do
      get '' do
        [200, icon.to_json]
      end

      put '' do
        update_icon!
        render_updated(icon)
      end

      delete '' do
        icon.destroy
        [204, {}]
      end
    end

    private

    def icon_id
      @icon_id ||= params[:icon_id]
    end

    def icon
      @icon ||= find_or_build_icon!
    end

    def find_or_build_icon!
      icon_id.present? ? Icon.find(icon_id) : Icon.new(icon_params)
    rescue ActiveRecord::RecordNotFound
      render_error(404, ["Could not find a(n) icon with id: #{icon_id}"])
    end

    def create_icon!
      return if icon.save

      render_error(422, icon.errors.to_hash)
    end

    def update_icon!
      return if icon.update(icon_params)

      render_error(422, icon.errors.to_hash)
    end

    def icon_params
      @icon_params ||= params_for(Icon)
    end

    def icons
      @icons ||= Icon.all
    end
  end
end
