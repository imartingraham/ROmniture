module ROmniture
	class TestAndTarget

		URL = 'https://testandtarget.omniture.com/api'

		def initialize(email, password, client, version, options = {})
			@params =  {
				:email => email,
				:password => password,
				:client => client,
				:version => version
			}

			@log = options[:log] ? options[:log] : false
			HTTPI.log = false
		end

		def get_campaign_list(state = 'activated', labels = nil)
			params = { :operation => 'campaignList', :state => state }


			if !labels.nil?
				params[:labels] = labels
			end

			send_request params

		end

		def get_campaign(id, start_date = nil, end_date = nil )
			params = {}
			if start_date.nil?
				start_date = 6.months.ago
			end

			if end_date.nil?
				end_date  = Date.tomorrow
			end

			params[:operation] = 'viewCampaign'
			params[:id] = id

			send_request params

		end

		def get_campaign_performance(campaign_id, start_date, end_date, segment = nil)
			params = {
				:resolution => 'day',
				:operation => 'report',
				:type => 'visitor',
				:start => start_date,
				:campaignId => campaign_id,
				:end => end_date,
				:filterExtremeOrders => true
			}

			if !segment.nil?
				params[:segment] = segment
			end
			send_request params
		end

    attr_writer :log

		def log?
			!@log != false
		end

		def logger
			@logger ||= ::Logger.new(STDOUT)
		end

		def log(*args)
			level = args.first.is_a?(Numeric) || args.first.is_a?(Symbol) ? args.shift : log_level
			logger.log(level, args.join(" ")) if log?
		end

		private 

		def send_request(params)
			begin
				log(Logger::INFO, "Requesting #{params[:operation]}")
				default_params = @params.clone
				merged_params = default_params.merge(params)
				request = HTTPI::Request.new(url:"#{URL}?#{merged_params.to_query}", open_timeout: 120, read_timeout: 120)
				puts request.url
				response = HTTPI.post(request)
				return response
			rescue Timeout::Error => e
				raise
			end
		end

	end

end