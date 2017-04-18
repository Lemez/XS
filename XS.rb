require_relative('./script')
require 'thor'

class XS < Thor


	desc "update audio spreadsheet", "Updating"

	option :new_local_csv, :type => :boolean
	option :add_to_local_csv, :type => :boolean
	option :new_remote_csv, :type => :boolean
	option :add_to_remote_csv, :type => :boolean
	option :convert_to_mp3, :type => :boolean

	option :vamp, :type => :string

	option :test_csv, :type => :boolean
	option :test_audio, :type => :boolean
	option :list_drive, :type => :boolean

	def main

		@media="The-Wonder-That-Is-Sanskrit-Devabhasha"
		@files = Dir.glob("../#{@media}/media/*/*.wav")

		@convert_to_mp3 = options[:convert_to_mp3]
		@add_to_local_csv = options[:add_to_local_csv]
		@add_to_remote_csv = options[:add_to_remote_csv]
		@new_local_csv = options[:new_local_csv]
		@new_remote_csv = options[:new_remote_csv]

		@vamp = options[:vamp]

		@test_csv = options[:test_csv]
		@test_audio = options[:test_audio]
		@list_drive = options[:list_drive]
		
		init_drive if options.keys.include?('csv')
		write_to_csv if @new_local_csv
		add_to_csv if @add_to_local_csv 
		list_drive_files if @list_drive

		unless @vamp.empty? || @vamp.nil?
			@files = Dir.glob("./audio_test/*.wav") if @test_audio

			vamp_process(@vamp)
			p @vamp_results
		end


	end


	# upload_to_drive("./outfile.csv", "Mantra Database") if @new_remote_csv

	XS.start
end