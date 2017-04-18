require 'csv'
require "google_drive"
require 'open3'

class Numeric
  def percent_of(n)
    (self.to_f / n.to_f * 100.0).round(1)
  end
end

#  ---------------------------

# TO DO 
# Not upload new CSV but change existing one now that main is there

# https://github.com/gimite/google-drive-ruby

# First worksheet of
# ws = session.spreadsheet_by_key(MANTRA_DATABASE).worksheets[0]

# Gets content of A2 cell: p ws[2, 1]  #==> "hoge"
# Changes content of cells:  ws[2, 2] = "bar"; ws.save

# p ws.rows / ws.num_rows / ws.num_cols  #==> [["fuga", ""], ["foo", "bar]]

#  ---------------------------

# Use VAMP in Command Line:
# eg:
# vamp qm-vamp-plugins:qm-keydetector "path-to-wav"
# vamp nnls-chroma:tuning "path-to-wav"

# useful:
# vamp -L
# vamp --list-by-category

#  ---------------------------

# USE THOR FOR COMMAND LINE ARGS // http://whatisthor.com/

# run with 
# ruby script.rb  hello


		MANTRA_DATABASE = "1FXSL2Afc0eASI3ZWUIs19kqz7d7TjHSfqSnioqkjzJ8"

		def init_drive
			@session = GoogleDrive::Session.from_config("config.json")
		end

		def add_open_permissions
			@session.files.first.acl.push({
				type: "anyone", allow_file_discovery: false, role: "reader"})
		end

		def delete_current_permissions
			@session.files.each{|f| f.acl.delete(f.acl[1])}
		end

		def list_drive_files
			init_drive
			@session.files.each{|f| p f; p f.acl}

		end

		def upload_to_drive(path,name)
			@session.upload_from_file(path, name, convert: false)
			add_open_permissions
		end

		def upload_mp3_to_drive(path,name)
			@session.upload_from_file(path, name, convert: false)
			add_open_permissions
		end

		def get_url_of_file
			"https://drive.google.com/file/d/#{@session.files[0].id}/view"
		end

		def save_mp3 (f,chapter)
			fname = File.basename(f)[0..-5]
			%x[mkdir 'mp3/#{@media}'] unless Dir.exists?('mp3/#{@media}')
			%x[mkdir 'mp3/#{@media}/#{chapter}'] unless Dir.exists?('mp3/#{@media}/{chapter}')
			%x[sox '#{f}' 'mp3/#{@media}/#{chapter}/#{fname}.mp3'] unless File.exists?('mp3/#{@media}/#{chapter}/#{fname}.mp3')
		end

		def vamp_process(plugin)
			case plugin
			when 'tonic'
				@plugin = "qm-vamp-plugins:qm-keydetector"
			when 'tonic-specific'
				@plugin = "qm-vamp-plugins:qm-keydetector:tonic"
			when 'yin'
				@plugin = "pyin:yin"
			when 'pyin'
				@plugin = "pyin:pyin"
			when 'chroma'
				@plugin = 'qm-vamp-plugins:qm-chromagram'
			when 'nnls-chroma'
				@plugin = 'nnls-chroma:nnls-chroma'
			when 'tuning'
				@plugin = 'nnls-chroma:tuning'
			when 'melodia'
				@plugin = 'mtg-melodia:melodia'
			else
				@plugin=plugin
			end

			@vamp_results = {}
			@files[0..2].each do |f|

				@vamp_results[f] = {}
				stdout, stderr, status = Open3.capture3("vamp-simple-host #{@plugin} '#{f}'")

				case plugin
				when 'tonic'
					begin
						# result = stdout.split(/\n/)[1].gsub('\n',"")
					rescue
						# next
					end
					p "#{@plugin} #{f}"
					stdout.split(/\n/).each{|line| p line}

					# tonic = result[-2..-1].gsub(" ","")
					# p "#{tonic}: #{f}"
					# @vamp_results[f]['tonic'] = tonic
				when 'tonic-specific'
					p "#{@plugin} #{f}"
					stdout.split(/\n/).each{|line| p line}

				when 'yin'
					begin
						# result = stdout.split(/\n/)
					rescue
						# next
					end
					p "#{@plugin} #{f}"
					stdout.split(/\n/).each{|line| p line}
					# result[0..10].each{|line| p line}

					# @vamp_results[f]['yin'] = yin
				when 'pyin'
					begin
						# result = stdout.split(/\n/)
					rescue
						# next
					end
					p "#{@plugin} #{f}"
					stdout.split(/\n/).each{|line| p line}
					# result[0..10].each{|line| p line}

					# @vamp_results[f]['yin'] = yin
				when 'chroma'
					lines = stdout.split(/\n/)
					number_of_lines = lines.size

					# what's important which position in the array 1-12, ie where the value is, rather than what the value is
					@notes = {0=>"C",1=>"C#",2=>"D",3=>"D#",4=>"E",5=>"F",6=>"F#",7=>"G",8=>"G#",9=>"A",10=>"Bb",11=>"B"}
					max_array = []
					max2_array = []

					lines.each do |line|
						sample_index = line.split(":")[0]
						result_array = line.split(":")[-1].split(" ").reject{|a|a.empty?}
						
						max = result_array.map(&:to_f).max
						max2 = (result_array - [max.to_s]).map(&:to_f).max
						max_position = result_array.index(max.to_s)
						max_position2 = result_array.index(max2.to_s)
						
						max_array << @notes[max_position]
						max2_array << @notes[max_position2]

						# p "---"
						# p "sample index: #{sample_index}; position:  #{@notes[max_position]};log: #{Math.log(max)}; log2: #{Math.log2(max)}"
						# p "sample index: #{sample_index}; position:  #{@notes[max_position2]};log: #{Math.log(max2)}; log2: #{Math.log2(max2)}"
					end

						chroma1 = max_array.uniq.max_by{ |i| max_array.count( i ) }
						count1 = max_array.count(chroma1).percent_of(number_of_lines)
						chroma2 = max2_array.uniq.max_by{ |i| max2_array.count( i ) }
						count2 = max2_array.count(chroma2).percent_of(number_of_lines)

						second_chroma1 = (max_array.uniq - [chroma1]).max_by{ |i| max_array.count( i ) }
						second_count1 = max_array.count(second_chroma1).percent_of(number_of_lines)
						second_chroma2 = (max2_array.uniq - [chroma2]).max_by{ |i| max2_array.count( i ) }
						second_count2 = max2_array.count(second_chroma2).percent_of(number_of_lines)
						
						third_chroma1 = (max_array.uniq - [chroma1,second_chroma1]).max_by{ |i| max_array.count( i ) }
						third_count1 = max_array.count(third_chroma1).percent_of(number_of_lines)
						third_chroma2 = (max2_array.uniq - [chroma2,second_chroma2]).max_by{ |i| max2_array.count( i ) }
						third_count2 = max2_array.count(third_chroma2).percent_of(number_of_lines)
						
						p "#{@plugin} #{f}"
						p "#{number_of_lines} 1st: #{chroma1}: #{count1}% ; runner-up: #{chroma2}: #{count2}%"
						p "#{number_of_lines} 2nd: #{second_chroma1}: #{second_count1}% ; runner-up: #{second_chroma2}: #{second_count2}%"
						p "#{number_of_lines} 3rd: #{third_chroma1}: #{third_count1}% ; runner-up: #{third_chroma2}: #{third_count2}%"

				when 'tuning'

					@notes = {0=>"C",1=>"C#",2=>"D",3=>"D#",4=>"E",5=>"F",6=>"F#",7=>"G",8=>"G#",9=>"A",10=>"Bb",11=>"B"}					

					p stdout

				when 'melodia'

					p "#{@plugin} #{f}"
					stdout.split(/\n/).each_with_index{|line,index| p line if index%50==0 && line.split(":")[-1].strip.to_f>0}

				when 'nnls-chroma'

					p "#{@plugin} #{f}"
					stdout.split(/\n/).each_with_index{|line,index| p line if index%10==0}
				else
					p "#{@plugin} #{f}"
					stdout.split(/\n/).each{|line| p line}
				end

			end
			
		end

		def get_number_of_columns
			CSV.open('outfile.csv', 'r', :headers=>true) do |csv|
				return csv.first.to_a.size
			end
		end

		def add_to_csv
			@cols = get_number_of_columns
			@test ? file = 'outfile copy.csv' : file = 'outfile.csv' 

			CSV.open(file, 'a+', :headers=>true) do |csv|
				
			end
		end

		def write_to_csv

			@performer="Sampadananda Mishra"
			@headers = %w(Media Chapter Performer FileName Duration Channels SampleRate Precision FileSize BitRate SampleEncoding Link)

			CSV.open('outfile.csv','wb', col_sep: ",") do |csvfile|
				csvfile << @headers
				@files.each do |wav|
					@chapter = wav.scan /Chap[0-9]+/
					@chapter = @chapter.first.split("Chap").last
					@file = wav.split("/").last
					@row = [@media, @chapter, @performer, @file]
					@row << %x[soxi -d '#{wav}']

					bla = %x[soxi #{wav}].split(/\n/).reject{|x|x.empty?||x.include?("Duration")||x.include?("Input File")}
					bla.each{|line|  @row << line.split(": ")[-1]}

					mp3name = @file[0...@file.index(".")]

					upload_mp3_to_drive("./mp3/#{@media}/#{@chapter}/#{mp3name}.mp3","#{mp3name}.mp3")
					@row << get_url_of_file #gets id of latest upload
					
					csvfile << @row unless @row.size ==4

					# save_mp3(wav,@chapter) unless wav.empty? || @chapter.empty?
					
				end
			end
		end



