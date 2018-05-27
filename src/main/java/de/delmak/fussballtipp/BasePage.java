package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Phase;
import org.apache.wicket.markup.html.WebPage;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;

public class BasePage extends WebPage
{

	private String mode = WicketApplication.MODE_BROWSE;

	public final String getMode()
	{
		return mode;
	}

	public final void setMode(String mode)
	{
		this.mode = mode;
	}

	public BasePage()
	{
		add(new BookmarkablePageLink("lnkHome", HomePage.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkRanking", Ranking.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkChat", Chat.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkGroupView", GroupView.class).add(new BookmarkablePageLinkBehaviour()));
		
		PageParameters paramsAllMatches = new PageParameters();
		paramsAllMatches.add("viewmode", BetView.BETVIEWMODE_MATCH);
				
		add(new BookmarkablePageLink("lnkAllMatches", BetView.class, paramsAllMatches).add(new BookmarkablePageLinkBehaviour()));		

		ListView rptPhases = new ListView<Phase>("rptPhases", Phase.getListAll()) {

			@Override
			protected void populateItem(ListItem<Phase> item)
			{
				Phase phase = (Phase) item.getModelObject();
				
				PageParameters params = new PageParameters();
				params.add("viewmode", BetView.BETVIEWMODE_MATCH);
				params.add("phaseid", phase.getPhaseId());
				
				BookmarkablePageLink lnkPhase = new BookmarkablePageLink("lnkPhase", BetView.class, params);
				lnkPhase.add(new Label("lblPhaseDescription", new PropertyModel(phase, "description")));
				lnkPhase.add(new BookmarkablePageLinkBehaviour());
				item.add(lnkPhase);
			}
		};

		add(rptPhases);

		PageParameters paramsSpecialBets = new PageParameters();
		paramsSpecialBets.add("viewmode", BetView.BETVIEWMODE_SPECIAL);
				
		add(new BookmarkablePageLink("lnkSpecialBets", BetView.class, paramsSpecialBets).add(new BookmarkablePageLinkBehaviour()));
		
		add(new BookmarkablePageLink("lnkUserSettings", UserSettings.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkRules", Rules.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkUserEntryFeeAdministration", UserEntryFeedAministration.class).add(new BookmarkablePageLinkBehaviour()));

		add(new BookmarkablePageLink("lnkUserAdministration", UserAdministration.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkRoleAdministration", RoleAdministration.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkTeamAdministration", TeamAdministration.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkPhaseAdministration", PhaseAdministration.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkBetgroupAdministration", BetgroupAdministration.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkLogin", LoginPage.class).add(new BookmarkablePageLinkBehaviour()));
		add(new BookmarkablePageLink("lnkLogout", LogoutPage.class).add(new BookmarkablePageLinkBehaviour()));
		
		IModel loginStatusModel;
		loginStatusModel = new Model<String>()
		{
			@Override
			public String getObject()
			{
				if (UserSession.get().isSignedIn())
				{
					return "Benutzer ist angemeldet. Name: "
							.concat(UserSession.get().getCurrentUser().getFirstname())
							.concat(" ")
							.concat(UserSession.get().getCurrentUser().getLastname());					
				}
				else
				{
					return "Benutzer ist nicht angemeldet.";
				}
			}
		};
		
		add(new Label("lblLoginStatus", loginStatusModel));
	}
}
