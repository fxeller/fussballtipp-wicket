package de.delmak.fussballtipp.persistence;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Team extends HibernateObject
{

	private Integer teamId;

	public Integer getTeamId()
	{
		return teamId;
	}

	public void setTeamId(Integer teamId)
	{
		this.teamId = teamId;
	}

	private String teamname;

	public String getTeamname()
	{
		return teamname;
	}

	public void setTeamname(String teamname)
	{
		this.teamname = teamname;
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
	
	private Set bracketTeams = new HashSet();

	public Set getBracketTeams()
	{
		return bracketTeams;
	}

	public void setBracketTeams(Set bracketTeams)
	{
		this.bracketTeams = bracketTeams;
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getTeamname());
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

	public static void insert(Team object)
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
	
	public static void modify(Team object)
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
	
	public static void delete(Team object)
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
	
	public static Team getById(int id)
	{
		try
		{
			beginTransaction();
			
			Team result = (Team) getSession()
					.getNamedQuery("getTeamById")
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

	public static Team getByName(String name)
	{
		try
		{
			beginTransaction();
			
			Team result = (Team) getSession()
					.getNamedQuery("getTeamByName")
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
					.getNamedQuery("getTeamsAll")
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
	
	public static List getListByBracketId(Integer bracketId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getTeamsByBracketId")
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
