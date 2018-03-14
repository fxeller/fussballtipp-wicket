package de.delmak.fussballtipp.persistence;

import static de.delmak.fussballtipp.persistence.HibernateObject.beginTransaction;
import static de.delmak.fussballtipp.persistence.HibernateObject.commitTransaction;
import static de.delmak.fussballtipp.persistence.HibernateObject.getSession;
import static de.delmak.fussballtipp.persistence.HibernateObject.rollbackTransaction;
import java.util.List;

public class UserBetgroup extends HibernateObject
{

	private Integer userBetgroupId;

	public Integer getUserBetgroupId()
	{
		return userBetgroupId;
	}

	public void setUserBetgroupId(Integer userBetgroupId)
	{
		this.userBetgroupId = userBetgroupId;
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

	private Betgroup betgroup;

	public Betgroup getBetgroup()
	{
		return betgroup;
	}

	public void setBetgroup(Betgroup betgroup)
	{
		this.betgroup = betgroup;
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s_%s", getClass().getName(), getUser().getUserId(), getBetgroup().getBetgroupId());
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
	
	public static List getUsersByBetgroupId(Integer betgroupId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getUsersByBetgroupId")
					.setInteger("betgroupId", betgroupId)
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
	
	public static List getBetgroupsByUserId(Integer userId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBetgroupsByUserId")
					.setInteger("userId", userId)
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
