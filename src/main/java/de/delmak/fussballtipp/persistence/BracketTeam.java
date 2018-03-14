package de.delmak.fussballtipp.persistence;

import de.delmak.fussballtipp.HibernateUtil;
import java.util.List;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class BracketTeam extends HibernateObject
{

	private Integer bracketTeamId;

	public Integer getBracketTeamId()
	{
		return bracketTeamId;
	}

	public void setBracketTeamId(Integer bracketTeamId)
	{
		this.bracketTeamId = bracketTeamId;
	}
	
	private Bracket bracket;

	public Bracket getBracket()
	{
		return bracket;
	}

	public void setBracket(Bracket bracket)
	{
		this.bracket = bracket;
	}

	private Team team;

	public Team getTeam()
	{
		return team;
	}

	public void setTeam(Team team)
	{
		this.team = team;
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s_%s", getClass().getName(), getBracket().getBracketId(), getTeam().getTeamId());
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

	public static void insert(BracketTeam object)
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
	
	public static void delete(BracketTeam object)
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
	
	public static BracketTeam getById(int id)
	{
		try
		{
			beginTransaction();
			
			BracketTeam result = (BracketTeam) getSession()
					.getNamedQuery("getBracketTeamById")
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
	
	public static List getListByBracketId(Integer bracketId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBracketTeamsByBracketId")
					.setInteger("bracketId", bracketId)
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
