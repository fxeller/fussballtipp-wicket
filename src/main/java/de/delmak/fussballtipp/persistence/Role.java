package de.delmak.fussballtipp.persistence;

import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class Role extends HibernateObject
{

	private Integer roleId;

	public Integer getRoleId()
	{
		return roleId;
	}

	public void setRoleId(Integer roleId)
	{
		this.roleId = roleId;
	}

	private String rolename;

	public String getRolename()
	{
		return rolename;
	}

	public void setRolename(String rolename)
	{
		this.rolename = rolename;
	}

	private String description;

	public String getDescription()
	{
		return description;
	}

	public void setDescription(String description)
	{
		this.description = description;
	}
	
	private Set userRoles = new HashSet();

	public Set getUserRoles()
	{
		return userRoles;
	}

	public void setUserRoles(Set userRoles)
	{
		this.userRoles = userRoles;
	}
	
	public UserRole findUserRole(User user)
	{
		UserRole result = null;
		UserRole find = new UserRole();

		find.setRole(this);
		find.setUser(user);

		Iterator<UserRole> iterUserRoles = this.getUserRoles().iterator();
		
		while (iterUserRoles.hasNext() == true)
		{
			UserRole nextUserRole = iterUserRoles.next();
			
			if (nextUserRole.equals(find) == true)
			{
				result = nextUserRole;
				
				break;
			}
		}
		
		return result;
	}
	
	public void addUser(User user)
	{
		UserRole userRole = new UserRole();
		
		userRole.setRole(this);
		userRole.setUser(user);
		this.getUserRoles().add(userRole);
	}
	
	public void delUser(User user)
	{
		UserRole userRole = findUserRole(user);
		
		if (userRole != null)
		{
			this.getUserRoles().remove(userRole);
		}
	}
	
	public void mergeUser(Set users)
	{
		this.getUserRoles().clear();
		
		Iterator<User> iterUsers = users.iterator();
		
		while (iterUsers.hasNext() == true)
		{
			addUser(iterUsers.next());
		}
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getRolename());
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

	public static void insert(Role object)
	{
		try
		{
			beginTransaction();
			getSession().save(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void modify(Role object)
	{
		try
		{
			beginTransaction();
			getSession().update(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void delete(Role object)
	{
		try
		{
			beginTransaction();
			getSession().delete(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Role getById(int id)
	{
		try
		{
			beginTransaction();
			
			Role result = (Role) getSession()
					.getNamedQuery("getRoleById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

	public static Role getByName(String name)
	{
		try
		{
			beginTransaction();
			
			Role result = (Role) getSession()
					.getNamedQuery("getRoleByName")
					.setString("name", name)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static List getListAll()
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getRolesAll")
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
}
