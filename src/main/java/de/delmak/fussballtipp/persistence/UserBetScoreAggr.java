package de.delmak.fussballtipp.persistence;

import static de.delmak.fussballtipp.persistence.HibernateObject.beginTransaction;
import static de.delmak.fussballtipp.persistence.HibernateObject.commitTransaction;
import static de.delmak.fussballtipp.persistence.HibernateObject.getSession;
import static de.delmak.fussballtipp.persistence.HibernateObject.rollbackTransaction;
import java.util.List;

public class UserBetScoreAggr extends HibernateObject
{

	private Integer userId;

	public Integer getUserId()
	{
		return userId;
	}

	public void setUserId(Integer userId)
	{
		this.userId = userId;
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

	private Integer score;

	public Integer getScore()
	{
		return score;
	}

	public void setScore(Integer score)
	{
		this.score = score;
	}

	private Integer rank;

	public Integer getRank()
	{
		return rank;
	}

	public void setRank(Integer rank)
	{
		this.rank = rank;
	}

	private Integer winparts;

	public Integer getWinparts()
	{
		return winparts;
	}

	public void setWinparts(Integer winparts)
	{
		this.winparts = winparts;
	}

	private Integer betgroupId;

	public Integer getBetgroupId()
	{
		return betgroupId;
	}

	public void setBetgroupId(Integer betgroupId)
	{
		this.betgroupId = betgroupId;
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getUser().getUserId());
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

	public static List getListByBetgroupId(Integer betgroupId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getUserBetScoresByBetgroupId")
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
		
	public static Integer getWinPartsByBetgroupId(Integer betgroupId)
	{
		try
		{
			beginTransaction();
			
			Long longResult = (Long) getSession()
					.getNamedQuery("getWinPartsByBetgroupId")
					.setInteger("betgroupId", betgroupId)
					.uniqueResult();
			
			commitTransaction();
			
			Integer result = longResult.intValue();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
}
