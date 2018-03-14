package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.User;
import org.apache.wicket.validation.IValidatable;
import org.apache.wicket.validation.IValidator;
import org.apache.wicket.validation.ValidationError;

public class UserPasswordValidator implements IValidator<String>
{

	@Override
	public void validate(IValidatable<String> validatable)
	{
		User user = UserSession.get().getCurrentUser();
		
		if ((user == null) || user.isUserPassword(validatable.getValue()) == false)
		{
			validatable.error(new ValidationError("Das Passwort ist falsch."));
		}
	}
	
}
