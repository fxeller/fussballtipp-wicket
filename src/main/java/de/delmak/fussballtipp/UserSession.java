package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.User;
import de.delmak.fussballtipp.persistence.UserRole;
import java.util.Iterator;
import org.apache.wicket.Session;
import org.apache.wicket.authroles.authentication.AuthenticatedWebSession;
import org.apache.wicket.authroles.authorization.strategies.role.Roles;
import org.apache.wicket.request.Request;

public class UserSession extends AuthenticatedWebSession
{

	public UserSession(Request request)
	{
		super(request);
	}
	
	public static UserSession get()
	{
		return (UserSession) Session.get();
	}
	
	private User currentUser;

	public User getCurrentUser()
	{
		return currentUser;
	}

	public void setCurrentUser(User currentUser)
	{
		this.currentUser = currentUser;
	}
	
	private Roles currentUserRoles = new Roles();

	public Roles getCurrentUserRoles()
	{
		return currentUserRoles;
	}

	public void setCurrentUserRoles(Roles currentUserRoles)
	{
		this.currentUserRoles = currentUserRoles;
	}

	@Override
	protected boolean authenticate(String username, String password)
	{
		setCurrentUser(null);

		User user = User.getByName(username);
		
		if ((user != null) && (user.isUserPassword(password) == true))
		{
			setCurrentUser(user);
			
			Iterator<UserRole> iterUserRoles = user.getUserRoles().iterator();
			
			while (iterUserRoles.hasNext() == true)
			{
				getCurrentUserRoles().add(iterUserRoles.next().getRole().getRolename());
			}

			return true;
		}
		else
		{
			return false;
		}
	}

	@Override
	public Roles getRoles()
	{
		Roles resultRoles = new Roles();
		
		if (isSignedIn() == true)
		{
			resultRoles.add("USER");
			resultRoles.addAll(getCurrentUserRoles());
		}
		else
		{
			resultRoles.add("GUEST");
		}
		
		return resultRoles;
	}
	
}
