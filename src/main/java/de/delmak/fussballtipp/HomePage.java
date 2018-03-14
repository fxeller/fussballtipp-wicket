package de.delmak.fussballtipp;

import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;

public class HomePage extends BasePage
{

	public HomePage()
	{
		add(new BookmarkablePageLink("lnkRulesHome", Rules.class).add(new BookmarkablePageLinkBehaviour()));
		
		WebMarkupContainer pnlSignedInHome = new WebMarkupContainer("pnlSignedInHome");
		pnlSignedInHome.setVisible(UserSession.get().isSignedIn() == true);
		add(pnlSignedInHome);
	}
}
