package de.delmak.fussballtipp;

import org.apache.wicket.Component;
import org.apache.wicket.Page;
import org.apache.wicket.behavior.AttributeAppender;
import org.apache.wicket.behavior.Behavior;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.model.Model;


public class BookmarkablePageLinkBehaviour extends Behavior
{

	@Override
	public void onConfigure(Component component) 
	{
		if (component instanceof BookmarkablePageLink)
		{
			BookmarkablePageLink link = (BookmarkablePageLink) component;
			Page page = link.getPage();
			
			Boolean linksToCurrentPage = ((link.getPageClass().equals(page.getClass()) == true) && (link.getPageParameters().equals(page.getPageParameters()) == true));
			Boolean linksToHomepageAfterLogout = ((link.getPageClass().equals(HomePage.class) == true) && (page.getClass().equals(LogoutPage.class) == true));
			
			if ((linksToCurrentPage == true) || (linksToHomepageAfterLogout == true))
			{
				link.add(new AttributeAppender("class", Model.of(" active")));
			}
		}
	}
}
