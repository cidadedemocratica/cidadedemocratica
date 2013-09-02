# -*- encoding : utf-8 -*-
module Authorization
  module StatefulRoles
    unless Object.constants.include? "STATEFUL_ROLES_CONSTANTS_DEFINED"
      STATEFUL_ROLES_CONSTANTS_DEFINED = true # sorry for the C idiom
    end

    def self.included( recipient )
      recipient.extend( StatefulRolesClassMethods )
      recipient.class_eval do
        include StatefulRolesInstanceMethods

        acts_as_state_machine :initial => :pending
        state :passive
        state :pending
        state :active,  :enter => :do_activate
        state :suspended
        state :deleted, :enter => :do_delete

        event :register do
          transitions :from => :passive, :to => :pending
        end

        event :activate do
          transitions :from => [:passive, :pending], :to => :active
        end

        event :suspend do
          transitions :from => [:passive, :pending, :active], :to => :suspended
        end

        event :delete do
          transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
        end

        event :unsuspend do
          transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.confirmed_at.blank? }
          transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.confirmation_token.blank? }
          transitions :from => :suspended, :to => :passive
        end
      end
    end

    module StatefulRolesClassMethods
    end # class methods

    module StatefulRolesInstanceMethods
      # Returns true if the user has just been activated.
      def recently_activated?
        @activated
      end

      def do_delete
        self.deleted_at = Time.now.utc
      end

      def do_activate
        @activated = true
        self.confirmed_at = Time.now.utc
        self.confirmation_token = nil
        self.deleted_at = nil
      end
    end # instance methods
  end
end
