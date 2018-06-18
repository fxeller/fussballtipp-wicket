package de.delmak.fussballtipp.persistence;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Bracket extends HibernateObject
{

	private Integer bracketId;

	public Integer getBracketId()
	{
		return bracketId;
	}

	public void setBracketId(Integer bracketId)
	{
		this.bracketId = bracketId;
	}

	private String bracketname;

	public String getBracketname()
	{
		return bracketname;
	}

	public void setBracketname(String bracketname)
	{
		this.bracketname = bracketname;
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
	
	private Phase phase;

	public Phase getPhase()
	{
		return phase;
	}

	public void setPhase(Phase phase)
	{
		this.phase = phase;
	}

	private Set bracketTeams = new HashSet();

	public Set getBracketTeams()
	{
		return bracketTeams;
	}

	public void setBracketTeams(Set bracketTeams)
	{
		this.bracketTeams = bracketTeams;
	}

	public Boolean getIsOpenForBets()
	{
		Calendar currentDateTime = Calendar.getInstance();
		Calendar closingDateTime = Calendar.getInstance();
		closingDateTime.setTime(BracketMinDatetime.getById(getBracketId()).getDatetime());
		closingDateTime.add(Calendar.MINUTE, -150);
		
		return (currentDateTime.before(closingDateTime) == true);
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getBracketname());
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

	public static void insert(Bracket object)
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
	
	public static void modify(Bracket object)
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
	
	public static void delete(Bracket object)
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
	
	public static Bracket getById(int id)
	{
		try
		{
			beginTransaction();
			
			Bracket result = (Bracket) getSession()
					.getNamedQuery("getBracketById")
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

	public static Bracket getByName(String name)
	{
		try
		{
			beginTransaction();
			
			Bracket result = (Bracket) getSession()
					.getNamedQuery("getBracketByName")
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
					.getNamedQuery("getBracketsAll")
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
	
	public static List getListByPhaseId(Integer phaseId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBracketsByPhaseId")
					.setInteger("phaseId", phaseId)
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
