require 'rubygems'
require 'mechanize'
require 'pp'
require 'watir'
#----------------------- Settings -----------------------------------------------
sleep_time= 300# time in seconds
# list of users
ati_users =          [ ["nikod555","55nikod55"],["gav333","78gav78"],["kal555","56kal67"],["vit77","77vit77"],["leo345","345leo345"],["step444","edcvfr"],["lvptr","rfdews"],["rudek","48fy56fy"],["sadoner","sedrftg"],["123max","34max34"],["123fed123","aqwsde33"],["orl999","66vbn66"],["oldbv123","123edr45"],["sax789","789sax789"],["shura77","zse45rdx"],["viktor900","900lop900"],["kov80","80kov80"],["ihorm","gt567ujki"],["pall1984","ijuhy67"],["kiril777","77kiril77"] ]
ukrtrans_users =     [ ["misha777","misha777"],["mko-mko","zxcvbnm"],["traltrans","misha12345"],["traltransp","misha123456"] ]
vashmagazin_users =  [ ["mko-mko@list.ru","f26ff"],["traltrans@ukr.net","ab234"],["kmo-kmo@list.ru","5b44d"] ]

def start_inet
   begin
     %x[ gnome-terminal -x bash -c "echo 1 | sudo -S  wvdial" ]

   rescue Exception => e
    puts e.message
    puts e.backtrace
    puts e.class
   end

end

def stop_inet
   begin
    %x[echo 1 | sudo -S   killall wvdial]
    sleep(5)
   rescue Exception => e
    puts e.message
    puts e.backtrace
    puts e.class
   end

end

#----------------------------------- flagma.ua --------------------------------
def update_flagma(counter,ati_users)
  user = ati_users[counter%ati_users.size]
  msg_counter = counter%3 + 1
  begin
   browser = Watir::Browser.new
   browser.goto "http://flagma.ua/login"
   browser.text_field(id: "LoginForm_username").set user[0]
   browser.text_field(id: "LoginForm_password").set user[1]
   browser.button(id: "login_button_main").click
   id = browser.p(class: "new-message-link").link.href.split("/")[-2]
   browser.goto "http://zhitomir.flagma.ua/my/#{id}/obyavleniya.html"
   cs=0
   ads=[]    
   browser.checkboxes(:class => 'item-checkbox').map { |ad| ads << ad.value }
   ads.each_slice(3) do |slice|
    cs+=1
     if cs == msg_counter 
      slice.each do |ad|
        browser.goto("http://zhitomir.flagma.ua/o#{ad}-e")
        sleep 5
	browser.button(class: "button-message").click
      	puts "--> Message id=#{ad} updated"
      end
     end
    	
   end
   browser.close if browser
  rescue Exception => e
    puts e.message
    puts e.backtrace
    puts e.class
    browser.close if browser
  end
end
#-----------------------------------------------


def update_ati(counter,ati_users)

transport_active = "no"  # set to "yes" to activate transport update
transports= 10  # amount of transports to be updated at once  ( max = 50 )
  user = ati_users[counter%ati_users.size]
   msg_counter = counter%3 + 1
  begin
  puts "#{user[0]} ... #{user[1]}"
  puts "#{msg_counter}"
 
 agent = Mechanize.new


  p = agent.get("http://www.traltrans.com.ua/delivery")  
 page = agent.get("http://www.ati.com.ua")
  if agent.page.links_with(:href => %r{/other/unauthorize.php}).size > 0
	  agent.page.links_with(:href => %r{/other/unauthorize.php}).first.click
  end
  form = page.forms.first
  username_field = form.field_with(:name => "user_name")
  username_field.value = user[0]
  password_field = form.field_with(:name => "user_pass")
  password_field.value = user[1]
  page1= form.click_button
  page2= agent.get("http://www.ati.com.ua/edit/bb_edit.php")
  page2.links_with(:href => %r{/bb}).first.click
  id_arr=[]
  agent.page.forms.last.checkboxes.each do |box|
  	name=box.name
	name.slice!('p')
	id_arr << name
  end
   cs=0
    id_arr.each_slice(3)  do |slice|
       cs+=1
        if cs == msg_counter
	  slice.each do |id|
	   puts "--> Message id=#{id} updated"
	   agent.get("http://www.ati.com.ua/edit/bb_update.php?id=#{id}")
	  end
        end
    end
#--------------- transport update ----------------
if transport_active == "yes"
    agent.get("http://www.ati.com.ua/transport/")
    agent.page.links_with(:href => %r{/transport})[1].click
 lc=0
agent.page.links_with(:href => %r{/edit/ct_edit.php}).reverse[0..transports*2].each do |item|
 	if lc == 0
		lc=1
		update_page=item.click
		update_page.forms.last.click_button

 	else
		lc=0
	end
 end
end
#form = agent.page.forms.last

    puts "--> transport updated"
    agent.page.links_with(:href => %r{/other/unauthorize.php}).first.click
    puts "====> #{user[0]} - item updated successfully"

  rescue Exception => e
    puts e.message
    puts e.backtrace
    puts e.class

  end
end

def update_vashmagazin(counter,vashmagazin_users)
  user = vashmagazin_users[counter%vashmagazin_users.size]
  n = (counter/vashmagazin_users.size)
  puts "#{user[0]}--- msg---->#{n}"
  begin

    agent = Mechanize.new
 page = agent.get("http://vashmagazin.com.ua")
 if agent.page.links_with(:href => %r{logout}).size > 0
	agent.page.links_with(:href => %r{logout}).first.click
 end
 page = agent.get("http://vashmagazin.com.ua/login.html")


    form = page.forms.first
    username_field = form.field_with(:name => "email")
    username_field.value = user[0]
    password_field = form.field_with(:name => "password")
    password_field.value = user[1]
    page1= form.click_button
 if n > 9
  page1=agent.get("http://vashmagazin.com.ua/cpanel-p2.html")
  number=n-10
 else
  number=n
 end
 page1.links_with(:href=>%r{prolongation})[number].click
 page1.links_with(:href=>%r{logout})[0].click
rescue Exception => e
    puts e.message
    puts e.backtrace
    puts e.class

  end
end


def update_ukrtrans(counter, ukrtrans_users)

  user = ukrtrans_users[counter%ukrtrans_users.size]
  n = (counter/ukrtrans_users.size)%10
  puts "#{user[0]}--- msg---->#{n}"
  begin
 agent = Mechanize.new
 page = agent.get("http://ukrtransport.com/system/login.php")
 if agent.page.links_with(:href => %r{logout}).size > 0
	agent.page.links_with(:href => %r{logout}).first.click
 end
 page = agent.get("http://ukrtransport.com/system/login.php")


    form = page.forms.first
    username_field = form.field_with(:name => "f_login")
    username_field.value = user[0]
    password_field = form.field_with(:name => "f_pass")
    password_field.value = user[1]
    page1= form.click_button

  page1 = page1.link_with(:href=>%r{/board/user_}).click
    #page1=agent.get("http://ukrtransport.com/board/user_35391_0_0.php")
   l = page1.links_with(:href=>%r{/del})[n]
   s = l.href
   s=s.gsub("del","povtor")
   s=s.gsub("php","html")
   page=agent.get("http://ukrtransport.com#{s}")




 page1.links_with(:href=>%r{/system/login.php?leng=1&unlog=1})[0].click
rescue Exception => e
    puts e.message
    puts e.backtrace
    puts e.class

  end
end
#--------------------------- Body -----------------------------------------------------
msg_counter=0
puts "-----------> Program started!"
counter=0
while(1) do
#  stop_inet
  sleep(10)
 # start_inet
  #sleep(sleep_time)


  update_vashmagazin(counter,vashmagazin_users)
  update_ukrtrans(counter, ukrtrans_users)
  #update_ati(counter,ati_users)
  update_flagma(counter,ati_users)
  counter+=1
 
  sleep(sleep_time)
end

#-----------------------



