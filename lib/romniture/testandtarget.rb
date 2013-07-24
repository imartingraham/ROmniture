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

		def get_campaign_list(labels = nil)
			params = { :operation => 'campaignList' }


			if !labels
				params[:labels] = 'AN Campaign, A/B...N, Live in Last 7 Days, Approved'
			else
				params[:labels] = labels
			end

			send_request params

		end

		def get_campaign(id, start_date = nil, end_date = nil )
			if start_date.nil?
				start_date = 6.months.ago
			end

			if end_date.nil?
				end_date  = Date.tomorrow
			end

			params[:operation] = 'viewCampaign'
			params[:id] = id

			send_request

		end

		def get_campaign_performance(campaign_id, start_date, end_date, segment = nil)
			params = {
				:resolution => 'day',
				:operation => 'report',
				:type => 'visotor',
				:start => start_date,
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
			log(Logger::INFO, "Requesting #{params[:operation]}")
			@params.merge(params)

			request = HTTPI::Request.new


			request.url = URL << '?' << @params.to_query

			puts HTTPI.post(request)

		end

	end

end