module TheAudit
  module Base
    extend ActiveSupport::Concern

    included do
      include BaseSorts

      scope :by_ip, ->(params){
        return nil unless ip = params[:ip]
        where(ip: ip)
      }

      scope :by_controller_action, ->(params){
        ca = params[:controller_action]
        return nil if ca.blank?

        ctrl, act = ca.split '-'
        return nil if act.blank?

        where(controller_name: ctrl).where(action_name: act)
      }

      belongs_to :user
      belongs_to :obj, polymorphic: true
    end

    def init controller, object = nil, data = {}
      self.obj             = object
      self.action_name     = controller.action_name
      self.controller_name = controller.controller_name

      self.data = data.to_json unless data.blank?

      if r = controller.request
        self.ip          = r.ip
        self.user_agent  = r.user_agent
        self.remote_ip   = r.remote_ip
        self.remote_addr = r.remote_addr
        self.remote_host = r.remote_host
        self.fullpath    = CGI::unescape(r.fullpath || '')
        self.referer     = CGI::unescape(r.referer  || 'direct_visit')
      end

      self
    end
  end
end
