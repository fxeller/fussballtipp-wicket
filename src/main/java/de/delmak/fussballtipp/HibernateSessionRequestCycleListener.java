package de.delmak.fussballtipp;

import org.apache.wicket.request.IRequestHandler;
import org.apache.wicket.request.cycle.AbstractRequestCycleListener;
import org.apache.wicket.request.cycle.RequestCycle;

public class HibernateSessionRequestCycleListener extends AbstractRequestCycleListener
{

	@Override
	public void onRequestHandlerExecuted(RequestCycle cycle, IRequestHandler handler)
	{
		HibernateUtil.closeSession();
	}
	
}
