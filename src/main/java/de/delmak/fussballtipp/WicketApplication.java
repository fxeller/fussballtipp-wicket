package de.delmak.fussballtipp;

import org.apache.wicket.RuntimeConfigurationType;
import org.apache.wicket.Session;
import org.apache.wicket.authorization.strategies.CompoundAuthorizationStrategy;
import org.apache.wicket.authroles.authentication.AbstractAuthenticatedWebSession;
import org.apache.wicket.authroles.authentication.AuthenticatedWebApplication;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AnnotationsRoleAuthorizationStrategy;
import org.apache.wicket.authroles.authorization.strategies.role.metadata.MetaDataRoleAuthorizationStrategy;
import org.apache.wicket.markup.html.WebPage;
import org.apache.wicket.request.Request;
import org.apache.wicket.request.Response;

public class WicketApplication extends AuthenticatedWebApplication
{
	public static final String MODE_BROWSE = "BROWSE";
	public static final String MODE_INSERT = "INSERT";
	public static final String MODE_MODIFY = "MODIFY";
	public static final String MODE_DELETE = "DELETE";

	@Override
	public void init()
	{
		super.init();
		
		getRequestCycleSettings().setResponseRequestEncoding("UTF-8"); 
		getRequestCycleListeners().add(new HibernateSessionRequestCycleListener());
        getMarkupSettings().setDefaultMarkupEncoding("UTF-8"); 
	
		CompoundAuthorizationStrategy strategy = new CompoundAuthorizationStrategy();
		strategy.add(new AnnotationsRoleAuthorizationStrategy(this));
		strategy.add(new MetaDataRoleAuthorizationStrategy(this));
		strategy.add(new BookmarkabelPageLinkAuthorizationStrategy(this));

		getSecuritySettings().setAuthorizationStrategy(strategy);
	}

	@Override
	public RuntimeConfigurationType getConfigurationType()
	{
		return RuntimeConfigurationType.DEPLOYMENT;
		//return RuntimeConfigurationType.DEVELOPMENT;
	}


	
	@Override
	public Class<? extends WebPage> getHomePage()
	{
		return HomePage.class;
	}

	@Override
	protected Class<? extends AbstractAuthenticatedWebSession> getWebSessionClass()
	{
		return UserSession.class;
	}

	@Override
	public Session newSession(Request request, Response response)
	{
		return new UserSession(request);
	}

	@Override
	protected Class<? extends WebPage> getSignInPageClass()
	{
		return LoginPage.class;
	}
	
}
