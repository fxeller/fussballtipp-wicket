package de.delmak.fussballtipp.persistence;

import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class Betgroup extends HibernateObject
{

	private Integer betgroupId;

	public Integer getBetgroupId()
	{
		return betgroupId;
	}

	public void setBetgroupId(Integer betgroupId)
	{
		this.betgroupId = betgroupId;
	}

	private String betgroupname;

	public String getBetgroupname()
	{
		return betgroupname;
	}

	public void setBetgroupname(String betgroupname)
	{
		this.betgroupname = betgroupname;
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
	
	private Set userBetgroups = new HashSet();

	public Set getUserBetgroups()
	{
		return userBetgroups;
	}

	public void setUserBetgroups(Set userBetgroups)
	{
		this.userBetgroups = userBetgroups;
	}
	
	public UserBetgroup findUserBetgroup(User user)
	{
		UserBetgroup result = null;
		UserBetgroup find = new UserBetgroup();

		find.setBetgroup(this);
		find.setUser(user);

		Iterator<UserBetgroup> iterUserBetgroups = this.getUserBetgroups().iterator();
		
		while (iterUserBetgroups.hasNext() == true)
		{
			UserBetgroup nextUserBetgroups = iterUserBetgroups.next();
			
			if (nextUserBetgroups.equals(find) == true)
			{
				result = nextUserBetgroups;
				
				break;
			}
		}
		
		return result;
	}
	
	public void addUser(User user)
	{
		UserBetgroup userBetgroup = new UserBetgroup();
		
		userBetgroup.setBetgroup(this);
		userBetgroup.setUser(user);
		this.getUserBetgroups().add(userBetgroup);
	}
	
	public void delUser(User user)
	{
		UserBetgroup userBetgroup = findUserBetgroup(user);
		
		if (userBetgroup != null)
		{
			this.getUserBetgroups().remove(userBetgroup);
		}
	}
	
	public void mergeUser(Set users)
	{
		this.getUserBetgroups().clear();
		
		Iterator<User> iterUsers = users.iterator();
		
		while (iterUsers.hasNext() == true)
		{
			addUser(iterUsers.next());
		}
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getBetgroupname());
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

	public static void insert(Betgroup object)
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
	
	public static void modify(Betgroup object)
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
	
	public static void delete(Betgroup object)
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
	
	public static Betgroup getById(int id)
	{
		try
		{
			beginTransaction();
			
			Betgroup result = (Betgroup) getSession()
					.getNamedQuery("getBetgroupById")
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

	public static Betgroup getByName(String name)
	{
		try
		{
			beginTransaction();
			
			Betgroup result = (Betgroup) getSession()
					.getNamedQuery("getBetgroupByName")
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
					.getNamedQuery("getBetgroupsAll")
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
