
# Friendsy (A Rails Social Media App Demo)

  

This project was completed for the [Facebook Clone project on The Odin Project](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-on-rails/lessons/rails-final-project) which serves as the Rails Final Project
You can view the project live on [Heroku](https://friendsy.herokuapp.com/).
## Project Summary (From The Odin Project)
You’ll be building Facebook. As usual, any additional styling will be up to you but the really important stuff is to get the data and back end working properly. You’ll put together some of the core features of the platform – users, profiles, “friending”, posts, news feed, and “liking”. You’ll also implement sign-in with the real Facebook by using OmniAuth and Devise.

Some features of Facebook we haven’t yet been exposed to – for instance chat, realtime updates of the newsfeed, and realtime notifications. You won’t be responsible for creating those unless you’d like to jump ahead and give it a shot.

 ##  Summary Of Features

- Users can sign up for an account using on-site registration or by Omniauth through Github or Facebook
	- New Users receive a welcome email as well (this may end up in spam!)
- Users can customize their Name, User/Nickname, Avatar image, and Banner image.
	- User Info, such as location and education, currently exist as a placeholder since this is a demo site and doesn't require any real personal information. 
- Users can add other users as friends. 
	- A user can see the posts of their friends in their main feed and message users in their friends list.
- Users can create Groups!
	- Groups may be marked as public or private
	- There is no 'invite' feature for private groups in this demonstration.
	- Private groups are not visible to non-members of the group. This includes posts made to the group by friends or on the "groups" tab of a user's profile.
	- Groups do have a creator with edit permissions, however there is no "group" user that can create posts for the group. Groups are intended to act as a social hub (like a subreddit).
- Users can create Journals (posts).
	- Journals can be directed to a user or to a group. 
	- By default, a journal is directed to the user making the post, a "self post".
	- A user's profile shows all of their self posts and all posts made on their profile.
	- A group's profile shows all posts made on their group page.
- Users can comment on Journals and on other comments!
	- Comments made to comments will be nested under the parent comment
	- Nested comments have a visual indentation to display their relation
- Users can "like" a Journal or a Comment
- Users can send real-time direct messages to other users
- Users receive notifications when:
	- Receiving a journal post
	- Receiving a comment on their journal or comment
	- Receiving a like
	- Receiving an unread message
	- Receiving a friend request
	- When an outgoing friend request is accepted
  

## Hotwire Usage
This project makes use of the [Hotwire for Rails gem](https://github.com/hotwired/hotwire-rails). Soon, this feature will come as a default in Rails 7 so I wanted to experiment with it now.

### Turbo Frames
Turbo frames are used for quick-loading regions of the website by only loading content that is necessary and leaving the rest as-is. This is used for the Profiles and Notification dropdown in two different ways.
- **Profile** *(Eager Loaded Turbo Frame)*
	- Profiles have a Turbo Frame surrounding the region containing the individual page content and navigation buttons. That means that when you go from a User's Timeline (i.e. /users/1) to a User's Friend's List (users/1/friendships), you do not do a full page redirect and content such as the banner and sidebars do not change and reload. Your browser will also stay located on your initial page, such as /users/1. You can still directly link to a page such as /friendships, however.
- **Notifications** *(Lazy Loaded Turbo Frame)*
	- The notification "dropdown" is also a turbo frame. Rather than being a physical drop-down menu, it actually has an external button (the icon you click) with a data attribute. What this actually does is send a request (GET) to your controller for the path you linked to, like normal. Instead of redirecting your browser however, it will locate the content inside of the path's view's `turbo_frame_tag` and insert that content into your currently loaded page which gives the illusion of a dropdown. 
	- Example. Clicking the `link_to` will send a `GET` request to the `friendships_path`'s respective controller action. Instead of loading the respective `/friendships/index.html.erb` view, it will instead take the content inside of that view's `turbo_frame_tag` and insert it into your *currently loaded* page's `turbo_frame-tag`, replacing the contents that are inside of it (in this case, it is empty by default).
		- Link: `<%=  link_to  friendships_path, 'data-turbo-frame': "notification-dropdown" %>`
		- Lazy Turbo Frame: `<%=  turbo_frame_tag  id="notification-dropdown", target:  '_top'%>`
		- app/views/friendships/index.html.erb: `<%=  turbo_frame_tag  id="notification-dropdown" do  %>`
		![Filled turbo frame](https://i.imgur.com/dH0vTmd.gif)
#### Hotwire Turbo Streams
Turbo streams allow you to instantly modify a page without reloading anything. Simply append, replace, or remove a region using your controller! You can stream both "locally" where it only updates on the user who made the request, or broadcast it live!
- *Non-broadcasted:*
	- **Journal Posting**
		- Journal posts automatically prepend to the top of the timeline of the user who posted it. Other users must refresh their page to see the new post. I made this choice to make sure all private-post validations must be strictly followed and to save on resources as this would mean every user would almost always have an active stream individualized to their view. 
- *Broadcasted:*
	- **Comments**
		- Comments and nested comments are broadcasted! This means that you can instantly see any new comments being made as they are made. This was my first proof-of-concept using turbo broadcasting. While this feature is unimportant and comments do not need to be live updated, I really thought it would be fun and exciting! 
	- **Direct Messaging**
		- Direct messages to other users broadcast instantly. This means you can hold a conversation with another user without having to ever reload the page to submit your message nor to see theirs! There is also a separate conversation sidebar that will update automatically, placing the most recent conversation on top and displaying a pink dot if any messages are unread. Messages are considered as 'read' when the page displaying them is loaded (the show action) or when the receiving user creates a new message reply to the conversation (so that turbo streams, which do not go through the show action, have a way to mark as read). 
		- **EXAMPLE RECORDED ON LIVE HEROKU DEMO!**
![DM stream example](https://i.imgur.com/nCF3WZZ.gif)
#### Hotwire Stimulus
Stimulus is an accompanying Javascript framework that is designed around HTML first. It doesn't render or take over, it simply adds augments to your HTML and compliments it. For instance, it allows the form containing the "send a new message" form to reset after a message is sent. Since you are not reloading a page, your form would otherwise send the message but not clear the text and reset to a new state.
I also use this with the nested comments to show/reset/hide a "reply" form under every nested comment! 
  
## Challenges and Problem Solving:
This app was so fun to make, but also had a lot of challenges to solve. I am listing these for both my personal referene later as well as to guide those who may end up seeing similar issues or challenges. These include:
- **Challenge: Figuring out how to create a friendship and friend request model.**
	- Solution: In the end, I decided to create a friendship and "inverse friendship" for every user. While this does mean listings do double, on this scale I believe it should be fine and it does result in faster queries as you do not need to inspect the table to check for friendships where user A is included in the first or second column. I did, however, go for the "one listing per relationship" style in my Conversation model, which is able to fetch all conversations where the user is creating or receiving the conversation and find the respective partner of each situation. 
- **Challenge: How can users and groups share similarity on their profiles while keeping the app DRY?**
	- Solution: I decided to create a list of shared views and even a shared layout to render the partials with. Profile actions for users and groups both point to these shared files. In cases where there are some differences, the `instance_of(Group/User)` method allows to accommodate a unique change while keeping the profiles overall DRY. While this does break from convention somewhat, I believe the payoff is worth it and I prefer this solution than some kind of Profiles Controller with a User and Group module attachment.
- **Challenge: Turbo frames cannot use global variables, i.e. no `current_user`!!!!**
	- Solution: This solution is actually quite a challenge! For starters, if you were to simply pass `current_user: current user` as a local variable, ALL users who are watching the stream will be able to see anything you are hiding under a `if current_user == post.author` style statement. This is because it uses the local user variable during the stream and does not check the VIEWING `current_user`.  So I divide the solution into two parts:
		- **Solution A: When `current_user` does not need to influence anything immediately:**
			-Use `ActiveSupport::CurrentAttributes` and in the application controller, `Current.user = current_user`. This allows me to, for instance, have every streamed comment include a `Like` feature which contains (pseudocode) `<%  if likes.include?(Current.user) %>`. By default, a new comment cannot contain any likes so this allows for me to pass through a way of saying "current user" without the stream crashing due to a missing variable error, and since `Current.user == current_user` on every page load, people viewing the comment later will have the variable be accurate to their user ID specifically! (If you try to pass `current_user == Current.user`, inside of the stream itself it will not make a difference)
		- **Solution B: When `current_user` needs to be immediately used to display something like an edit button**:
			- **DO NOT USE THIS SOLUTION FOR ANY SENSITIVE INFORMATION OR FOR ANY LINKS THAT DO NOT CONTAIN CONTROLLER VALIDATION**. (Example: an edit comment button should use `current_user.authored_comments.find`, NOT, `comments.find`!!!)
			- I wrap the contents of the user-dependent buttons or styling in a div such as:
				-  `<span  class="edit-links user-<%=comment.comment_author.id%>-edit-links">`
			- In my styling I set `.edit-links` to `display: none`
			- In the app layout, I have `<style>` tags containing `<%=".user-#{current_user.id}-edit-links"%> {display: inline}`.
			- This means that only the current user can see the hidden edit link divs if their ids match. This works with live broadcasted material instantly and users do not have to refresh to see links nor will they see any not meant for them. In the case of the message feature, I used this to change the style of the message to align right and have a different background color!
- **Challenge: ActiveStorage  image variations result in a massive amount of N+1 queries!**
	- Solution: This is being solved on Rails 7 and some people have sort-of solved this with temporary initialize modules that allows the variations to group together a bit better, but you still have a chain of `attachment > blob > variation > attachment > blob` to get there. I found the solution for now is to swap to using the Carrierwave gem for file storage which cleanly includes the image directly as a string in the User's table listing and does not require any relations or inclusions or queries to fetch!
- **Challenge: OmniAuth results in an error of `Not found. Authentication passthru` & `CORS error`**
	- Solution: The error message I recieved was very generic and in most cases was related to people forgetting to make their `method: :post` or restart their server, so I spent a lot of time rechecking things that I could not find any issue with! After lots of testing, it turns out Hotwire's Turbo Drive causes issues with Omniauth. I was able to solve this by adding `:data => {turbo: "false"}` to my buttons for Omniauth. It seems that `link_to` is still not compatible with OA depsite this solution, but `button_to` works as intended. 
## Closing Thoughts
This project allowed me to reflect on a lot of what I have learned and gave me a space to truly explore what I know in a way that was free. I was able to impliment features in the way I felt was correct and wanted to, rather than being told how to do it or given instructions and guidance. I was also able to let myself explore and be creative by trying out brand new libraries I have never touched! (Carrierwave, Hotwire/Turbo, Omniauth)

## Issues & Potential Improvements:
**HTML RELATED**
- I could use more HTML tags such as `main, article, section, aside` to make sections clearer.

**CSS/VISUAL RELATED**
- The styling is not friendly to mobile devices or non-standard resolution ratios. The objective of this project is not styling, nor have I gone through the in-depth styling curriculum, but I would like to repair this later on when I learn more about CSS. 
- The sidebar where the notifications reside could use some content such as a mock "trending" tab or a list of online friends!
	- Alternatively, the sidebar could be removed entirely and the notification frame be absolutely positioned with a z-index to be on top of other content.
- The "Photos" tab of a user filters out Journals that include an image, but visually this may appear to not have done anything and could confuse a user when they click the tab and don't notice the change in filtering. Combined with Turbo Frames for quick loading, it may appear the button has done nothing at all and not even loaded a page!
- A light mode could be welcomed. This could be done by storing a value in a cookie for each user who toggles it on/off and updating the css respectively. (ties into backend)

**BACKEND RELATED**
- Mailer may get stuck in spam since the website is not validated.
- The "About" tab of a user is a placeholder, users could be allowed to add information such as a bio and have a page to display more in-depth information.
- "Likes" are not a part of the Hotwire scope and will refresh the page upon hitting the like/dislike button. This is because I feel Hotwire is potentially not a better solution than existing Javascript options that do this, but this needs more exploring.
- It may be preferable to reduce the nested associations related to a User's Friendship associations so that there is less to load (such as when loading the User index)
- The main timeline could be paginated and/or infinite loaded with Hotwire appending alongside a stimulus controller that tracks if the user has scrolled to the bottom of the page.

