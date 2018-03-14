package de.delmak.fussballtipp;

import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;

@AuthorizeInstantiation("USER")
public class LogoutPage extends BasePage
{

	public LogoutPage()
	{
		UserSession.get().invalidate();
	}
}
