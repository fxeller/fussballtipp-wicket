package de.delmak.fussballtipp;

import org.apache.wicket.Component;
import org.apache.wicket.Session;
import org.apache.wicket.authorization.Action;
import org.apache.wicket.authroles.authorization.strategies.role.AbstractRoleAuthorizationStrategy;
import org.apache.wicket.authroles.authorization.strategies.role.IRoleCheckingStrategy;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;

public class BookmarkabelPageLinkAuthorizationStrategy extends AbstractRoleAuthorizationStrategy
{

	public BookmarkabelPageLinkAuthorizationStrategy(IRoleCheckingStrategy roleCheckingStrategy)
	{
		super(roleCheckingStrategy);
	}

	@Override
	public boolean isActionAuthorized(Component component, Action action)
	{
		if ((BookmarkablePageLink.class.isInstance(component) == true) && ((action == Component.RENDER) || (action == Component.ENABLE)))
		{
			BookmarkablePageLink link = (BookmarkablePageLink)component;
			
			return Session.get().getAuthorizationStrategy().isInstantiationAuthorized(link.getPageClass());
		} 
		else
		{
			return true;
		}
	}	
	
}
