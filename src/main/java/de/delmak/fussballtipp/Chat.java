package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Betgroup;
import de.delmak.fussballtipp.persistence.UserBetgroup;
import de.delmak.fussballtipp.persistence.UserPost;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.basic.MultiLineLabel;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextArea;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;

@AuthorizeInstantiation("USER")
public class Chat extends BasePage
{

	static final Integer STEPWIDTH = 10;
	
	private Integer betgroupId;

	public final Integer getBetgroupId()
	{
		return betgroupId;
	}

	public final void setBetgroupId(Integer betgroupId)
	{
		this.betgroupId = betgroupId;
	}

	private Long userPostCount;

	public final Long getUserPostCount()
	{
		return userPostCount;
	}

	public final void setUserPostCount(Long userPostCount)
	{
		this.userPostCount = userPostCount;
	}

	private Integer firstResult;

	public final Integer getFirstResult()
	{
		return firstResult;
	}

	public final void setFirstResult(Integer firstResult)
	{
		this.firstResult = firstResult;
	}

	private String newPosting;

	public final String getNewPosting()
	{
		return newPosting;
	}

	public final void setNewPosting(String newPosting)
	{
		this.newPosting = newPosting;
	}

	public Chat(final PageParameters parameters)
	{
		List<Betgroup> betgroups = null;
		betgroups = UserBetgroup.getBetgroupsByUserId(UserSession.get().getCurrentUser().getUserId());

		StringValue paramBetgroupId = parameters.get("betgroupid");
		if (paramBetgroupId.isEmpty() == false)
		{
			setBetgroupId(paramBetgroupId.toInt());
		}
		else
		{
			setBetgroupId(betgroups.get(0).getBetgroupId());
		}

		StringValue paramFirstResultId = parameters.get("firstresult");
		if (paramFirstResultId.isEmpty() == false)
		{
			setFirstResult(paramFirstResultId.toInt());
		}
		else
		{
			setFirstResult(0);
		}
		
		setUserPostCount(UserPost.getUserPostCountByBetgroupId(getBetgroupId()));
		
		if ((getFirstResult() < 0) || (getFirstResult() > getUserPostCount()))
		{
			setFirstResult(0);
		}
				
		ListView rptBetgroupFilter = new ListView<Betgroup>("rptBetgroupFilter", betgroups)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Betgroup betgroup = (Betgroup) item.getModelObject();

					PageParameters params = new PageParameters();
					params.add("betgroupid", betgroup.getBetgroupId());
					
					BookmarkablePageLink lnkBetgroupFilter = new BookmarkablePageLink("lnkBetgroupFilter", Chat.class, params);
					lnkBetgroupFilter.add(new Label("lblBetgroupFilter", betgroup.getDescription()));
					lnkBetgroupFilter.add(new BookmarkablePageLinkBehaviour());
					item.add(lnkBetgroupFilter);
				}
			};
		
		rptBetgroupFilter.setVisible(betgroups.size() > 1);
		add(rptBetgroupFilter);

		setNewPosting("");
		
		Form frmAddPosting = new Form("frmAddPosting")
		{
			
			@Override
			protected void onSubmit()
			{
				UserPost userPost = new UserPost();
				userPost.setUser(UserSession.get().getCurrentUser());
				userPost.setBetgroup(Betgroup.getById(getBetgroupId()));
				userPost.setPost(getNewPosting());
				userPost.setCreatedate(Calendar.getInstance().getTime());
				
				UserPost.insert(userPost);
				
				PageParameters params = new PageParameters();
				params.add("betgroupid", getBetgroupId());
					
				setResponsePage(Chat.class, params);
			}
			
		};
		
		add(frmAddPosting);

		TextArea memNewPosting = new TextArea("memNewPosting", new PropertyModel(this, "newPosting"));
		memNewPosting.setRequired(true);
		frmAddPosting.add(memNewPosting);
		
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
		
		PageParameters paramsNewer = new PageParameters();
		paramsNewer.add("betgroupid", getBetgroupId());
		paramsNewer.add("firstresult", getFirstResult() - STEPWIDTH);
		
		BookmarkablePageLink lnkNewerUserPost = new BookmarkablePageLink("lnkNewerUserPost", Chat.class, paramsNewer);
		lnkNewerUserPost.setVisible(getFirstResult() > 0);
		add(lnkNewerUserPost);
		
		PageParameters paramsOlder = new PageParameters();
		paramsOlder.add("betgroupid", getBetgroupId());
		paramsOlder.add("firstresult", getFirstResult() + STEPWIDTH);

		BookmarkablePageLink lnkOlderUserPost = new BookmarkablePageLink("lnkOlderUserPost", Chat.class, paramsOlder);
		lnkOlderUserPost.setVisible(getFirstResult() < getUserPostCount() - STEPWIDTH);
		add(lnkOlderUserPost);
		
		ListView rptUserPosts = new ListView<UserPost>("rptUserPosts", UserPost.getUserPostsByBetgroupId(getBetgroupId(), getFirstResult())) {

			@Override
			protected void populateItem(ListItem<UserPost> item)
			{
				UserPost userPost = (UserPost) item.getModelObject();
				
				String fullname = userPost.getUser().getFirstname() + " " + userPost.getUser().getLastname();

				SimpleDateFormat formatterDate = new SimpleDateFormat("dd.MM.yyyy HH:mm");
				String creatDate = formatterDate.format(userPost.getCreatedate());

				item.add(new Label("lblUseFullname", fullname));
				item.add(new Label("lblCreateDate", creatDate));
				item.add(new MultiLineLabel("lblUserPost", new PropertyModel(userPost, "post")));
				
				Link lnkDeletUserPost = new Link("lnkDeletUserPost", item.getModel()) {

					@Override
					public void onClick()
					{
						UserPost userPost = (UserPost) this.getModelObject();
						
						if (userPost.getUser().equals(UserSession.get().getCurrentUser()) == true)
						{
							UserPost.delete(userPost);
						}
						
						PageParameters params = new PageParameters();
						params.add("betgroupid", getBetgroupId());

						setResponsePage(Chat.class, params);
					}
				};
						
				lnkDeletUserPost.setVisible(userPost.getUser().equals(UserSession.get().getCurrentUser()) == true);
				item.add(lnkDeletUserPost);
			}
		};
				
		add(rptUserPosts);
	}
}
