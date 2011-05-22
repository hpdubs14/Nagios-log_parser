#!/usr/bin/env ruby


require 'pathname'
require 'fileutils'
require 'CSV'
require 'time'

#Parsing regex patterns
nagios_log = /\w*:(\w+\s\d+)(\s\d+:\d+:\d+)\s+cm-logging-01 nagios:\s+(service alert|service notification|current service state):(\s+cm-pconsole-[0-9]{2}[a-z]);(.*);(\w+);(\w+);(\w+);(\w*):(.*) /i
nagios_errors = /PCONSOLE STAGE3 DOWNLOAD ERROR LOG.*|PCONSOLE CAD PROCESS ERROR LOG.*|PCONSOLE STAGE3 PROCESS ERROR LOG|PCONSOLE STAGE1 ERROR FLAG.*|PCONSOLE STAGE1 DOWNLOAD ERROR LOG.*|PCONSOLE CAD ERROR FLAG.*|PCONSOLE STAGE3 UPLOAD ERROR LOG.*/i
regex_casenum = /.*B3[A-Z][A-Z][A-Z][ _]?\d{6}.*/i
regex_casematch = /.?(B3[a-z][a-z][a-z][ |_]\d{6}).*$/i

regex_err_dt_s = /.?(\d\d\/\d\d\/\d\d_\d\d:\d\d:\d\d).*$/i

file_gen_format = "#{Time.now.strftime"%Y%m%d"}_#{Time.now.strftime"%H%M%S"}_"


WORKING_DIR = Pathname.getwd
puts WORKING_DIR

#Check if file entry is valid
if  ARGV[0] == nil 
  p "Please enter path to Nagios log file"
  Process.exit
elsif Dir.glob(ARGV[0]).empty?
  p "Nagios log file is not found"
  Process.exit
end
nagios_path = ARGV[0].gsub('\\', '/')
nagios_parsefile = CSV.open("/#{nagios_path.gsub(nagios_path.split('/').last,"")}#{file_gen_format}nagios_parsed.csv", "w") 

File.foreach(nagios_path) do |line|
  if  line =~ nagios_log
    
    array = line.scan(nagios_log).flatten
    array = array.collect{|x| x.strip}
  
    #Filter errors information to get case number, dts
    if array[9] =~ regex_casematch
  
      err_casenum = array[9].scan(regex_casematch).flatten
   
      #reformat the original error date time data
      array[0] = Time.strptime(array[0].to_s + array[1].to_s, "%b %d%H:%M:%S")
      err_dt =  array[9].scan(regex_err_dt_s).flatten
      
      array.insert(9, err_casenum[0].to_s)     
      #Pull-out the error date/time
      begin
        array.insert(10, Time.strptime(err_dt[0].gsub('_',' ').to_s,"%m/%d/%y %H:%M:%S").to_time)
        array.delete_at(1)
        nagios_parsefile << array
      rescue
        # Moves past errors such as "B3MMM 818815 - Stage1DLError"
      next
      end
  
      next
    end
  end
end









# 
# 
# MPAUTO_PATH = "c:\\program files\\3D Systems\\Manufacturing Pro Automation\\v2.1.4\\MPAuto.exe"
# #Set home dir
# $Home_dir = Dir.pwd
# #Search for STL's
# stl_filenames_array = Dir.glob("*.stl", File::FNM_CASEFOLD).collect { |file| file}.sort
# 
# search_dir = Pathname.new(".").realpath
# style_folder = search_dir.children.find { |f| f.directory? and f.basename.to_s.downcase.include?("style")  }
# 
# #Group STL Components
# stl_filenames_groups_array = []
# stl_filenames_single_array = []
# 
# #Testing file naming formats
# case_number1=/\A(^B3[A-Z][A-Z][A-Z])[ _]?(\d{6})/
# case_number2=/(\d{6})/
# 
# #Parse file to get replacement filename from lookup table
# src_file = "SliceTestLookup.csv"
# idx = 0
# header_row = false
# lookup_array=[]
# keys = []
# 
# 
# 
# stl_filenames_array.each do |f|
#     group_test = f.chomp(".stl").split("_")
# 
#     if group_test.any? { |g| g.downcase.include?("group") or g.include?("lower") or g.include?("upper")}
#         stl_filenames_groups_array << f
#     elsif f.downcase.chomp(".stl") =~ loop_format
#     stl_filenames_groups_array << f
#     else
#         stl_filenames_single_array << f
#     end
# end
# 
# #Group STL's into array and set to appropriate format and key
# group_hash_array = []
# stl_filenames_groups_array.find_all do |f|
#   g_array =  f.downcase.chomp(".stl").split("_")
#    #puts f
#   if g_array[0] =~ case_number1 or g_array[0] =~ case_number2
#     insert_hash = {}
#     #puts "production case"
#     #puts f
#     if g_array.size == 3
#       insert_hash[:case],insert_hash[:baseloc],insert_hash[:model]=g_array
#       insert_hash[:filename]= f
#       group_hash_array << insert_hash
#     else
#       insert_hash[:case],insert_hash[:baseloc],insert_hash[:piece],insert_hash[:style],insert_hash[:stylecount]=g_array
#       insert_hash[:filename]= f
#       group_hash_array << insert_hash
#     end
#     #puts "hash = #{insert_hash.inspect}"
#     
#     #Test for looping/QA format
#     #test_description_type__test#_case#_part#  00_05percent_solid_2_056263_1
#   elsif f.downcase.chomp(".stl") =~ loop_format
#     insert_hash = {}
#     #puts "testing stl"
#     insert_hash[:run],insert_hash[:description],insert_hash[:type], insert_hash[:test], insert_hash[:case], insert_hash[:part] = g_array
#     insert_hash[:filename]= f
#     
#     group_hash_array << insert_hash
#     #puts "hash = #{insert_hash.inspect}"
#   elsif g_array.find_all { |g| g.downcase.include?("group")}
#     location = g_array.index(g_array.find { |g| g.downcase.include?("group")})
#     groupcasenumber = g_array[location]
#     insert_hash = {}
#     insert_hash[:case]=g_array[location]
#     insert_hash[:part]=g_array[location+1]
#     insert_hash[:filename]= f
#     group_hash_array << insert_hash
#     #puts insert_hash.inspect
#   else puts "#{f} didn't work!!!!!!!!!!!!! Need to use proper format"
#   
#   end
#   #puts "g_array = #{g_array.inspect}"
#   #puts "g_array.size = #{g_array.size}"
#   
# end
# #puts "group_hash_array = #{group_hash_array.inspect}"
# 
#  
# #Define style files
# part_build_style =''
# part_recoat_style = ''
# support_build_style = ''
# support_recoat_style = ''
# support_style = ''
# Dir.foreach(style_folder) do |f|
#     if f.downcase.include?("part_") and f.downcase.include?(".sty")
#       part_build_style = f
#       #puts "part build style = #{part_build_style.to_s}"
#     end
#     if f.downcase.include?("part_") and f.downcase.include?(".rcs")
#       part_recoat_style = f
#       #puts "part recoat style = #{part_recoat_style.to_s}"
#     end 
#     if f.downcase.include?("supt_") and f.downcase.include?(".sty")
#       support_build_style = f
#       #puts support_part_style.to_s
#     end
#     if f.downcase.include?("supt_") and f.downcase.include?(".rcs")
#       support_recoat_style = f
#       #puts support_recoat_style.to_s
#     end
#     if f.downcase.include?(".srg") or f.downcase.include?(".frg")
#       support_style = f
#     end
#     
# end
# 
# 
# style_folder = style_folder.to_s.gsub('/', '\\')
# style_file_block = 
# "Default Build Style=#{style_folder+'\\'+part_build_style}
# Default Recoat Style=#{style_folder+'\\'+part_recoat_style}
# Default Support Build Style=#{style_folder+'\\'+support_build_style}
# Default Support Recoat Style=#{style_folder+'\\'+support_recoat_style}
# Default Support Style=#{style_folder+'\\'+support_style}"
# 
# 
# 
# 
# def machine_properties(log_toggle, slice_toggle,style_folders,stl_file_dir,stl_file_path)
# 
# "[Machine Properties]
# Machine Name=Test_PRO
# Machine Type=IPRO9000
# Resin Name=Accura25
# Minimum Build Extent X=0
# Minimum Build Extent Y=0
# Minimum Build Extent Z=0
# Maximum Build Extent X=22
# Maximum Build Extent Y=25
# Maximum Build Extent Z=3.45
# Minimum Platform Extent X=0
# Minimum Platform Extent Y=0
# Minimum Platform Extent Z=0
# Maximum Platform Extent X=25.6
# Maximum Platform Extent Y=29.6
# Maximum Platform Extent Z=3.45
# Shrink Comp X=1.0050
# Shrink Comp Y=1.0050
# Shrink Comp Z=1
# Small Beam Width=0.0050
# Large Beam Width=0.03
# Use Gaussian=0
# Minimum Support Height=0.2559
# Slice Resolution Flag=3
# Small Spot LineWidth Comp=0.0635
# Large Spot LineWidth Comp=0.200
# #{style_folders}
# Default Build Directory=#{stl_file_dir.to_s.gsub('/', '\\')}
# [Platform Properties]
# X Margin=2
# Y Margin=1
# X Spacing=.2
# Y Spacing=.2
# Auto Part Placement=Simple
# Supports Angle=1
# Units=mm
# Log Style XML=#{log_toggle}
# Log Layout=#{log_toggle}
# Build Name=Test_Build
# Number Of Parts=1
# Slice Files=#{slice_toggle}
# Create BFF=No
# [Part 1]
# Part=#{stl_file_path.to_s.gsub('/', '\\')}
# Number of Build Styles=0
# Verify=Yes
# Create Supports=#{slice_toggle}
# Anchored=No
# Small Spot LineWidth Comp=0.0635
# Large Spot LineWidth Comp=0.200
# Number Of Support Build Styles=0"
# 
# 
# end
# #
# def group_machine_properties(log_toggle, slice_toggle,style_folders,stl_file_dir,sli_name,part_count)
# 
# "[Machine Properties]
# Machine Name=Test_PRO
# Machine Type=IPRO9000
# Resin Name=Accura25
# Minimum Build Extent X=0
# Minimum Build Extent Y=0
# Minimum Build Extent Z=0
# Maximum Build Extent X=22
# Maximum Build Extent Y=25
# Maximum Build Extent Z=3.45
# Minimum Platform Extent X=0
# Minimum Platform Extent Y=0
# Minimum Platform Extent Z=0
# Maximum Platform Extent X=25.6
# Maximum Platform Extent Y=29.6
# Maximum Platform Extent Z=3.45
# Shrink Comp X=1.0050
# Shrink Comp Y=1.0050
# Shrink Comp Z=1
# Small Beam Width=0.0050
# Large Beam Width=0.03
# Use Gaussian=0
# Minimum Support Height=0.2559
# Slice Resolution Flag=3
# Small Spot LineWidth Comp=0.0635
# Large Spot LineWidth Comp=0.200
# #{style_folders}
# Default Build Directory=#{stl_file_dir.to_s.gsub('/', '\\')}
# [Platform Properties]
# X Margin=2
# Y Margin=1
# X Spacing=.2
# Y Spacing=.2
# Auto Part Placement=Simple
# Supports Angle=1
# Units=mm
# Log Style XML=#{log_toggle}
# Log Layout=#{log_toggle}
# Build Name=Test_Build
# Number Of Parts=#{part_count}
# Slice Files=#{slice_toggle}
# Create BFF=No
# Number of Merge Sets = 1
# [Merge Set 1]
# Merge Slice File Name = #{stl_file_dir.to_s.gsub('/','\\')}\\#{sli_name}"
# end
# 
# def part_target (part_count, stl_file_path, slice_toggle)
# "
# [Part #{part_count}]
# Part=#{stl_file_path.to_s.gsub('/', '\\')}
# Number of Build Styles=0
# Verify=Yes
# Create Supports=#{slice_toggle}
# Anchored=No
# Small Spot LineWidth Comp=0.0635
# Large Spot LineWidth Comp=0.200
# Number Of Support Build Styles=0
# Merge Set = 1"
# end
# 
# CSV.open(src_file, 'r') do |f|
#   idx +=1
#   
#   if f[0] =~ /^\D*$/
#     puts "Found header at row #{idx}"
#     header_row = true
#     keys = f.collect {|g| g.downcase.to_sym }
#   elsif header_row == true
#     n=0
#      hash_insert = {}
#     keys.each do |i|
#       j = f[n]
#       hash_insert[i] = j
#       n += 1
#     end
#     
#     hash_insert.each do |key, value|
#      if value.empty? or value = nil
#        hash_insert[key] = "blank"
#      end
#     end
#     
#    
#     #puts lookup_array.inspect
#     #puts hash_insert.inspect
#     hash_insert[:test_folder_name] = hash_insert[:group].to_s+"_"+hash_insert[:description].to_s+"_"+hash_insert[:model_type].to_s+"_"+hash_insert[:iterative_number].to_s+"_"+hash_insert[:case_number].to_s
#     lookup_array << hash_insert
#    end
# 
# end
# 
# puts lookup_array.inspect
# 
#  puts "group hash array = #{group_hash_array.inspect}"
#  #Organize groups to execute folder creation and copy files
#   case_sort_hash={}
#   group_hash_array.each do |casename|
#     remove_ext = /_[\d*].[sS][tT][lL]$/
#     if casename.has_key?(:description)
#       case_sort_hash[casename[:filename].gsub(remove_ext,'')] ||= []
#       case_sort_hash[casename[:filename].gsub(remove_ext,'')] << casename[:filename]
#        
#     
#     elsif casename.has_key?(:baseloc)
#         lookup_array.find do |l|  
#             if l[:case_number] == casename[:case]
#                 puts "matching lookup #{l[:case_number].inspect} to grouphash #{casename[:case].inspect}"
#                 case_sort_hash[l[:test_folder_name]] ||= []
#                 case_sort_hash[l[:test_folder_name]] << casename[:filename]
#                 
#             end
#         end
#     else
#     # ||= means only assign if variable is nil
#     #puts "before assignment : case_sort_hash[casename[:case]] = #{case_sort_hash[casename[:case]].inspect}"
#     case_sort_hash[casename[:case]] ||= []
#     #puts "after assignment : case_sort_hash[casename[:case]] = #{case_sort_hash[casename[:case]].inspect}"
#     case_sort_hash[casename[:case]] << casename[:filename]
#     end
#   end
#   puts "case_sort_hash before test #{case_sort_hash.inspect}"
#   
#   #Remove additional pieces to be processed
#   case_sort_hash.collect do |key, value|
# 
#     if key =~ case_number2 or key =~ case_number1
#        upper_delete_location = ''
#        lower_delete_location = ''
#        lower_full_removal_flag = false
#        upper_full_removal_flag = false
#       
#         
#       value.each do |g|
#         
#         #Finds where full parts are
#         if g.downcase.include?("full") and g.downcase.include?("lower")
#           lower_delete_location =value.index(g)
#           #puts g
#           #puts lower_delete_location
#         elsif g.downcase.include?("full") and g.downcase.include?("upper")
#           upper_delete_location = value.index(g)
#           #puts g
#           #puts upper_delete_location
#         end
#       
#        #Determines if full needs to be removed      
#         if g.downcase.include?("operative") or g.downcase.include?("prep") and g.downcase.include?("lower")
#            lower_full_removal_flag = true
#            #puts g
#            #puts "lower flag on"
#          elsif g.downcase.include?("operative") or g.downcase.include?("prep") and g.downcase.include?("upper")
#           upper_full_removal_flag = true
#           #puts g
#           #puts "upper flag on"
#         end      
#        end
# 
#       #Delete full from moving if conditions are true
#       if lower_full_removal_flag == true and lower_full_removal_flag == true
#         puts lower_delete_location
#         puts "removed lower #{value[lower_delete_location]}"
#         value.delete_at(lower_delete_location)        
#       elsif  upper_full_removal_flag == true and upper_full_removal_flag == true
#         puts upper_delete_location
#         puts "removed upper #{value[upper_delete_location]}"
#         value.delete_at(upper_delete_location)    
#       end
#    
#     else
#       puts "skipped #{key}"
#     end    
#   end
#   puts "case_sort_hash after test #{case_sort_hash.inspect}"
#   
#   
#   create_folder = case_sort_hash.keys
#   puts "create_folder = #{create_folder.inspect}"
#   
# #Create case folders
#   create_folder.each do |f|
#     Dir.mkdir(f) unless Pathname.new(f).exist?
#   end
# 
# #Move cases to folders
#   case_sort_hash.each do |key, value|
#     value.each do |f|  
#     File.copy(Pathname(f).realpath, Pathname(key).realpath)
#     end
#   end
# #Create Slice_Params.INI file for folder
#   case_sort_hash.each do |key, value|
#     ini_path = Pathname(key).realpath.to_s 
#     slice_toggle = "Yes"
#     log_toggle = 1
#     sli_name = key.to_s + ".sli"
#     part_count = value.size
#     
#     File.open(ini_path+"\\slice_params.ini", 'w') do |f|
#     count = 1
#     f << group_machine_properties(log_toggle,slice_toggle,style_file_block,ini_path,sli_name,part_count)
#       value.each do |g|
#         stl_path = ini_path +"\\" +g
#         f << part_target(count,stl_path,slice_toggle)
#         count += 1
#       end
#     end
#   end
# #Create Slice_Prep_Params.INI file for folder
#   case_sort_hash.each do |key, value|
#     ini_path = Pathname(key).realpath.to_s 
#     slice_toggle = "No"
#     log_toggle = 0
#     sli_name = key.to_s + ".sli"
#     part_count = value.size
#     File.open(ini_path+"\\slice_prep_params.ini", 'w') do |f|
#     count = 1
#     f << group_machine_properties(log_toggle,slice_toggle,style_file_block,ini_path,sli_name,part_count)
#       value.each do |g|
#         f << part_target(count,Pathname(g).realpath ,slice_toggle)
#         count += 1
#       end
#     end
#   end
# #
# #Create Slice_Params.bat file for folder
#   case_sort_hash.each do |key, value|
#     ini_path = Pathname(key).realpath.to_s.gsub('/','\\') 
# 
#     File.open(ini_path+"\\slice_params.bat", 'w') do |f|
#       cmdlines =
# %|cd\\\n
# "#{MPAUTO_PATH}" "#{ini_path}\\slice_params.ini" "#{ini_path}\\BFFWizard.ini"\n EXIT %errorlevel% |
#       f << cmdlines
#     end
#   end
#   
# #Create Slice_Prep_Params.bat file for folder
#   case_sort_hash.each do |key, value|
#     ini_path = Pathname(key).realpath.to_s.gsub('/','\\') 
# 
#     File.open(ini_path+"\\slice_prep_params.bat", 'w') do |f|
#       cmdlines =
# %|cd\\\n
# "#{MPAUTO_PATH}" "#{ini_path}\\slice_prep_params.ini" "#{ini_path}\\BFFWizard.ini"\n EXIT %errorlevel% |
#       f << cmdlines
#     end
#   end
#   #
# stl_filenames_single_array.collect do |filename|
#   #Cut off STL extension
#   #puts "filename = #{filename.inspect}"
#   bfn = filename.gsub(/.[sS][tT][lL]$/,'')
#   #puts "bfn = #{bfn.inspect}"
#   #Create foldername from STL name with date
#   new_name = bfn.to_s
#   Dir.mkdir(new_name) unless Pathname.new(new_name).exist?
#   
#   #New folder created for STL
#   new_location = Pathname(new_name).realpath
# 
#   #Current Path of STL
#   location = Pathname(filename).realpath
# 
#   #Copy STL Files to created folders
#   #File.copy(location, new_location)
#   
#   #Create INI  
# 
#   #Change working directory to STL folder
#   Dir.chdir(new_location)
#   #Find all STL in folder and assign each as a part
#   part_filenames = Dir.glob("*.stl", File::FNM_CASEFOLD).collect { |file| Pathname(file).realpath}
#  
#   #puts part_filenames.inspect
# 
#   
#   #part_filenames.each do |f| 
#   #end
#   #part_paths = stl_filenames.children.find_all { |f| f.directory? and f.basename.to_s.downcase.include?(".stl") }
#   part_count = part_filenames.size
#   #puts part_count
#   
#   
#   
# 
#  File.open("slice_params.ini", 'w') do |f|
#    slice_toggle = "Yes"
#    log_toggle = 1
#    f << machine_properties(log_toggle,slice_toggle,style_file_block,new_location,part_filenames)
#    
#  end
#   File.open("slice_params.bat", 'w') do |f|
#    slice_toggle = "Yes"
#    log_toggle = 1
#    cmdlines =
# %|cd\\\n
# "c:\\program files\\3D Systems\\Manufacturing Pro Automation\\v2.1.4\\MPAuto.exe" "#{new_location.to_s.gsub('/', '\\')}\\slice_params.ini" "#{new_location.to_s.gsub('/', '\\')}\\BFFWizard.ini"\n EXIT %errorlevel% |
#    f << cmdlines
#   end
#  File.open("slice_prep_params.ini", 'w') do |f|
#    slice_toggle = "No"
#    log_toggle = 0
#    f << machine_properties(log_toggle,slice_toggle,style_file_block,new_location,part_filenames)
#   end  
#  File.open("slice_prep_params.bat", 'w') do |f|
#    slice_toggle = "Yes"
#    log_toggle = 1
#    cmdlines =
# %|cd\\\n
# "c:\\program files\\3D Systems\\Manufacturing Pro Automation\\v2.1.4\\MPAuto.exe" "#{new_location.to_s.gsub('/', '\\')}\\slice_prep_params.ini" "#{new_location.to_s.gsub('/', '\\')}\\BFFWizard.ini"\n EXIT %errorlevel%|
#    f << cmdlines
#   end 
#   #Change back to home directory
#   Dir.chdir($Home_dir)
# 
#   
#   
#   
#   #count = count + 1
#   #puts "Loop " + count.to_s
#   end
# 
# 
# #Case number test regex
# #a =~ /\A(^B3[A-Z][A-Z][A-Z])[ _]?(\d{6})/  OR use a.match(/regex/)
# 
# 
#  