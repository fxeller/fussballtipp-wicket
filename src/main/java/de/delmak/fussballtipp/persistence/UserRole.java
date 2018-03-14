package de.delmak.fussballtipp.persistence;

public class UserRole extends HibernateObject
{

	private Integer userRoleId;

	public Integer getUserRoleId()
	{
		return userRoleId;
	}

	public void setUserRoleId(Integer userRoleId)
	{
		this.userRoleId = userRoleId;
	}
	
	private User user;

	public User getUser()
	{
		return user;
	}

	public void setUser(User user)
	{
		this.user = user;
	}

	private Role role;

	public Role getRole()
	{
		return role;
	}

	public void setRole(Role role)
	{
		this.role = role;
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s_%s", getClass().getName(), getUser().getUserId(), getRole().getRoleId());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}

	
	
}
