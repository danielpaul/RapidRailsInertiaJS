# frozen_string_literal: true

class ExamplesController < ApplicationController
  def welcome_email
    # Simple page to demonstrate job enqueueing
    render inertia: "Examples/WelcomeEmail", props: {
      message: flash[:notice] || "Enter an email to test background job processing"
    }
  end

  def enqueue_welcome_email
    # API endpoint to enqueue a welcome email job
    if params[:email].present?
      WelcomeEmailJob.perform_later(params[:email], params[:name])
      
      render json: { 
        success: true, 
        message: "Welcome email queued for #{params[:email]}" 
      }
    else
      render json: { 
        success: false, 
        message: "Email is required" 
      }, status: :unprocessable_entity
    end
  end
end
